// app.js
import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import mysql from "mysql2";

const app = express();
app.use(cors());
app.use(bodyParser.json());

// adjust host/user/password/database as needed
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "mfu_rooms_pj1"
});

db.connect(err => {
  if (err) {
    console.log("❌ Database connection failed:", err);
    process.exit(1);
  } else {
    console.log("✅ Connected to MySQL database: mfu_rooms_pj");
  }
});

app.get("/", (req, res) => res.send("MFU Room Reservation Backend is running!"));

// LOGIN -> return { user: {...} } or null
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT id, username, role FROM users WHERE username = ? AND password = ?";
  db.query(sql, [username, password], (err, result) => {
    if (err) return res.status(500).json({ error: "db_error", details: err });
    if (result.length > 0) return res.json({ user: result[0] });
    return res.json({ user: null });
  });
});

// REGISTER (student only) - role defaults to student but we'll explicitly set
app.post("/register", (req, res) => {
  const { username, password } = req.body;
  const sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
  db.query(sql, [username, password], (err) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") return res.json({ ok: false, msg: "Username already exists" });
      return res.json({ ok: false, msg: "Database error" });
    }
    return res.json({ ok: true });
  });
});

// Get rooms (with disabled flag)
app.get("/rooms", (req, res) => {
  db.query("SELECT id, name, building, is_disabled FROM rooms ORDER BY name", (err, rows) => {
    if (err) return res.status(500).json({ error: "db_error" });
    // map is_disabled to integer 0/1
    const out = rows.map(r => ({ id: r.id, name: r.name, building: r.building, disabled: r.is_disabled ? 1 : 0 }));
    res.json(out);
  });
});

// Get bookings for a user
app.get("/bookings/:userId", (req, res) => {
  const { userId } = req.params;
  const sql = `
    SELECT 
      b.id, 
      b.timeslot, 
      DATE_FORMAT(b.date, '%Y-%m-%d') AS date,
      DATE_FORMAT(b.time, '%H:%i') AS time,
      b.status,
      r.name AS room, 
      r.building,
      u.username AS approved_by
    FROM bookings b
    JOIN rooms r ON b.room_id = r.id
    LEFT JOIN users u ON b.action_by = u.id
    WHERE b.user_id = ?
    ORDER BY b.id DESC
  `;
  db.query(sql, [userId], (err, rows) => {
    if (err) return res.status(500).json({ error: "db_error" });
    res.json(rows);
  });
});


// Book a room
app.post("/book", (req, res) => {
  const { userId, roomId, timeslot } = req.body;
  if (!userId || !roomId || !timeslot) return res.json({ ok: false, msg: "Invalid request" });

  const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
  const nowTime = new Date().toTimeString().slice(0,5) + ":00"; // HH:MM:00 for TIME

  // 1) check user active booking today
  const checkUserSql = `SELECT * FROM bookings WHERE user_id = ? AND date = ? AND (status = 'Pending' OR status = 'Approved')`;
  db.query(checkUserSql, [userId, today], (err, existing) => {
    if (err) return res.json({ ok: false, msg: "Database error (check user)" });
    if (existing.length > 0) return res.json({ ok: false, msg: "You already have an active booking today." });

    // 2) check slot availability for the room on this date
    const checkSlotSql = `SELECT * FROM bookings WHERE room_id = ? AND timeslot = ? AND date = ? AND (status = 'Pending' OR status = 'Approved')`;
    db.query(checkSlotSql, [roomId, timeslot, today], (err2, slot) => {
      if (err2) return res.json({ ok: false, msg: "Database error (check slot)" });
      if (slot.length > 0) return res.json({ ok: false, msg: "This time slot is not available." });

      // 3) ensure room isn't globally disabled
      const checkRoomSql = `SELECT is_disabled FROM rooms WHERE id = ?`;
      db.query(checkRoomSql, [roomId], (err3, rrows) => {
        if (err3) return res.json({ ok: false, msg: "Database error (check room)" });
        if (!rrows || rrows.length === 0) return res.json({ ok: false, msg: "Room not found." });
        if (rrows[0].is_disabled) return res.json({ ok: false, msg: "This room is disabled and cannot be booked." });

        // 4) insert pending booking
        const insertSql = `INSERT INTO bookings (user_id, room_id, timeslot, date, time, status) VALUES (?, ?, ?, ?, ?, 'Pending')`;
        db.query(insertSql, [userId, roomId, timeslot, today, nowTime], (err4) => {
          if (err4) return res.json({ ok: false, msg: "Insert failed" });
          return res.json({ ok: true, msg: "Booking request sent!" });
        });
      });
    });
  });
});

// Get room statuses for a date: returns [{ room_id, timeslot, status }]
app.get("/room-statuses/:date", (req, res) => {
  const date = req.params.date;
  // We'll return a list of statuses per room per timeslot
  const sql = `
    SELECT r.id AS room_id, r.name AS room_name, b.timeslot, b.status
    FROM rooms r
    LEFT JOIN bookings b ON r.id = b.room_id AND b.date = ?
    WHERE 1
    ORDER BY r.id
  `;
  db.query(sql, [date], (err, rows) => {
    if (err) return res.status(500).json({ error: "db_error" });
    // convert into map: { room_id: { '8-10': 'Pending', ... } }
    const map = {};
    rows.forEach(row => {
      const rid = row.room_id;
      if (!map[rid]) map[rid] = {};
      if (row.timeslot) map[rid][row.timeslot] = row.status;
    });
    res.json(map);
  });
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT} (or use 10.0.2.2:${PORT} from Android emulator)`);
});
