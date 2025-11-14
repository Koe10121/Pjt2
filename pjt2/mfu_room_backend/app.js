import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import mysql from "mysql2";
import bcrypt from "bcrypt";

const app = express();
app.use(cors());
app.use(bodyParser.json());

// Database connection
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
    console.log("✅ Connected to MySQL database: mfu_rooms_pj1");
  }
});

app.get("/", (req, res) => res.send("MFU Room Reservation Backend is running!"));

// ---------------- LOGIN ----------------
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT id, username, password, role FROM users WHERE username = ?";

  db.query(sql, [username], async (err, results) => {
    if (err) return res.status(500).json({ user: null, msg: "Database error during login." });
    if (results.length === 0) return res.json({ user: null, msg: "Incorrect username or password." });

    const user = results[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) return res.json({ user: null, msg: "Incorrect username or password." });

    // remove password before sending
    delete user.password;
    return res.json({ user, msg: "Login successful." });
  });
});

// ---------------- REGISTER ----------------
app.post("/register", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.json({ ok: false, msg: "Username and password are required." });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
    db.query(sql, [username, hashedPassword], (err) => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.json({ ok: false, msg: "Username already exists." });
        }
        return res.json({ ok: false, msg: "Database error." });
      }
      return res.json({ ok: true, msg: "Registration successful (password secured)." });
    });
  } catch (err) {
    return res.status(500).json({ ok: false, msg: "Server error during registration." });
  }
});

// ---------------- ROOMS ----------------
app.get("/rooms", (req, res) => {
  db.query("SELECT id, name, building, is_disabled FROM rooms ORDER BY name", (err, rows) => {
    if (err) return res.status(500).json({ error: "db_error", msg: "Database error fetching rooms." });
    const out = rows.map(r => ({
      id: r.id,
      name: r.name,
      building: r.building,
      disabled: r.is_disabled ? 1 : 0
    }));
    res.json(out);
  });
});

// ---------------- BOOKINGS ----------------
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
    if (err) return res.status(500).json({ error: "db_error", msg: "Database error fetching bookings." });
    res.json(rows);
  });
});

// ---------------- BOOK ----------------
app.post("/book", (req, res) => {
  const { userId, roomId, timeslot } = req.body;
  const date = new Date().toISOString().slice(0, 10);

  if (!userId || !roomId || !timeslot) {
    return res.json({ ok: false, msg: "Missing userId, roomId, or timeslot." });
  }

  const roomCheckSql = "SELECT is_disabled FROM rooms WHERE id = ?";
  db.query(roomCheckSql, [roomId], (err, rows) => {
    if (err) return res.json({ ok: false, msg: "Database error while checking room." });
    if (rows.length === 0) return res.json({ ok: false, msg: "Room not found." });

    const isDisabled = rows[0].is_disabled === 1;
    if (isDisabled) {
      return res.json({ ok: false, msg: "This room is currently disabled." });
    }

    const [_, endHourStr] = timeslot.split("-");
    const endHour = parseInt(endHourStr);

    const now = new Date();
    const utc = now.getTime() + now.getTimezoneOffset() * 60000;
    const thailandTime = new Date(utc + 7 * 3600000);

    const currentHour = thailandTime.getHours();
    const currentMinute = thailandTime.getMinutes();
    const currentTotal = currentHour * 60 + currentMinute;
    const endTotal = endHour * 60;

    if (currentTotal >= endTotal - 30)
      return res.json({ ok: false, msg: "This time slot has already passed." });

    const checkSql = `
      SELECT * FROM bookings
      WHERE user_id = ? AND date = ?
      AND (status = 'Pending' OR status = 'Approved')
    `;
    db.query(checkSql, [userId, date], (err, existing) => {
      if (err) return res.json({ ok: false, msg: "Database error." });
      if (existing.length > 0)
        return res.json({ ok: false, msg: "You already have an active booking today." });

      const slotSql = `
        SELECT * FROM bookings
        WHERE room_id = ? AND timeslot = ? AND date = ?
        AND (status = 'Pending' OR status = 'Approved')
      `;
      db.query(slotSql, [roomId, timeslot, date], (err, slot) => {
        if (err) return res.json({ ok: false, msg: "Database error." });
        if (slot.length > 0)
          return res.json({ ok: false, msg: "This time slot is not available." });

        const insertSql = `
          INSERT INTO bookings (user_id, room_id, timeslot, date, time, status)
          VALUES (?, ?, ?, ?, CURTIME(), 'Pending')
        `;
        db.query(insertSql, [userId, roomId, timeslot, date], (err) => {
          if (err) return res.json({ ok: false, msg: "Insert failed." });
          res.json({ ok: true, msg: "Booking request sent!" });
        });
      });
    });
  });
});

// ---------------- ROOM STATUSES (FOR A GIVEN DATE) ----------------
app.get("/room-statuses/:date", (req, res) => {
  const date = req.params.date;
  const sql = `
    SELECT 
      r.id AS room_id, r.name AS room_name, r.building, r.is_disabled,
      b.timeslot, b.status
    FROM rooms r
    LEFT JOIN bookings b ON r.id = b.room_id AND DATE(b.date) = ?
    ORDER BY r.id
  `;
  db.query(sql, [date], (err, rows) => {
    if (err) return res.status(500).json({ error: "db_error", msg: "Database error fetching statuses." });

    const map = {};
    rows.forEach(row => {
      const rid = row.room_id;
      if (!map[rid]) {
        map[rid] = {
          room_name: row.room_name,
          building: row.building,
          disabled: row.is_disabled ? 1 : 0,
          slots: { "8-10": "Free", "10-12": "Free", "13-15": "Free", "15-17": "Free" }
        };
      }
      if (row.is_disabled === 1) {
        map[rid].slots = {
          "8-10": "Disabled",
          "10-12": "Disabled",
          "13-15": "Disabled",
          "15-17": "Disabled"
        };
      } else if (row.timeslot) {
        if (row.status === "Approved") {
          map[rid].slots[row.timeslot] = "Approved";
        } else if (row.status === "Pending") {
          map[rid].slots[row.timeslot] = "Pending";
        } else {
          // Rejected OR any other non-blocking status → treat as Free
          map[rid].slots[row.timeslot] = "Free";
        }
      }
    });
    res.json(map);
  });
});


// ---------------- LECTURER: GET TODAY'S PENDING REQUESTS ----------------
app.get("/lecturer/requests", (req, res) => {
  const sql = `
    SELECT 
      b.id, 
      b.timeslot, 
      DATE_FORMAT(b.date, '%Y-%m-%d') AS date,
      DATE_FORMAT(b.time, '%H:%i') AS time,
      b.status,
      r.name AS room, 
      r.building,
      u.username AS requestedBy
    FROM bookings b
    JOIN rooms r ON b.room_id = r.id
    JOIN users u ON b.user_id = u.id
    WHERE b.status = 'Pending' AND DATE(b.date) = CURDATE()
    ORDER BY b.id DESC
  `;
  db.query(sql, (err, rows) => {
    if (err) {
      console.error("Error fetching lecturer requests:", err);
      return res.status(500).json({ ok: false, msg: "Database error fetching today's pending requests." });
    }
    res.json(rows);
  });
});


// ---------------- LECTURER: APPROVE or REJECT REQUEST ----------------
app.post("/lecturer/action", (req, res) => {
  const { lecturerId, bookingId, status } = req.body;

  if (!lecturerId || !bookingId || !status)
    return res.json({ ok: false, msg: "Missing lecturerId, bookingId, or status." });

  if (!["Approved", "Rejected"].includes(status))
    return res.json({ ok: false, msg: "Invalid status value." });

  // 1️⃣ Check if lecturerId belongs to lecturer
  const checkLecturerSql = "SELECT role FROM users WHERE id = ?";
  db.query(checkLecturerSql, [lecturerId], (err, rows) => {
    if (err) return res.json({ ok: false, msg: "Database error (lecturer check)." });
    if (rows.length === 0) return res.json({ ok: false, msg: "Lecturer not found." });

    if (rows[0].role !== "lecturer") {
      return res.json({ ok: false, msg: "Only lecturers can approve or reject." });
    }

    // 2️⃣ Check booking exists, is Pending, and is for today
    const checkBookingSql = `
      SELECT * FROM bookings
      WHERE id = ? AND DATE(date) = CURDATE()
    `;
    db.query(checkBookingSql, [bookingId], (err, bookingRows) => {
      if (err) return res.json({ ok: false, msg: "Database error (booking check)." });
      if (bookingRows.length === 0)
        return res.json({ ok: false, msg: "Booking not found or not from today." });

      const booking = bookingRows[0];

      if (booking.status !== "Pending") {
        return res.json({ ok: false, msg: "This booking is already processed." });
      }

      // 3️⃣ Update booking (safe)
      const updateSql = `
        UPDATE bookings
        SET status = ?, action_by = ?, time = CURTIME()
        WHERE id = ?
      `;
      db.query(updateSql, [status, lecturerId, bookingId], (err) => {
        if (err) {
          return res.json({ ok: false, msg: "Error updating booking." });
        }
        return res.json({ ok: true, msg: `Booking ${status} successfully.` });
      });
    });
  });
});

// ---------------- LECTURER: HISTORY ----------------
app.get("/lecturer/history/:lecturerId", (req, res) => {
  const { lecturerId } = req.params;

  const sql = `
    SELECT 
      b.id,
      b.timeslot,
      DATE_FORMAT(b.date, '%Y-%m-%d') AS date,
      DATE_FORMAT(b.time, '%H:%i') AS time,
      b.status,
      r.name AS room,
      r.building,
      u.username AS requestedBy
    FROM bookings b
    JOIN rooms r ON b.room_id = r.id
    JOIN users u ON b.user_id = u.id
    WHERE b.action_by = ? AND (b.status = 'Approved' OR b.status = 'Rejected')
    ORDER BY b.id DESC
  `;

  db.query(sql, [lecturerId], (err, rows) => {
    if (err) {
      console.error("Error fetching lecturer history:", err);
      return res.status(500).json({ ok: false, msg: "Database error fetching lecturer history." });
    }
    res.json(rows);
  });
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
