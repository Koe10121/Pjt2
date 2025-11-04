import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import mysql from "mysql2";

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ✅ Connect to your existing database
const db = mysql.createConnection({
  host: "localhost",
  user: "root", // change if needed
  password: "", // add password if your MySQL has one
  database: "mfu_rooms_pj"
});

db.connect(err => {
  if (err) {
    console.log("❌ Database connection failed:", err);
  } else {
    console.log("✅ Connected to MySQL database: mfu_rooms_pj");
  }
});

// 🧠 Root route
app.get("/", (req, res) => {
  res.send("MFU Room Reservation Backend is running!");
});

// 🧍 LOGIN
app.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT * FROM users WHERE username = ? AND password = ?";
  db.query(sql, [username, password], (err, result) => {
    if (err) return res.json({ error: err });
    if (result.length > 0) {
      res.json(result[0]);
    } else {
      res.json(null);
    }
  });
});

// 📝 REGISTER (student only)
app.post("/register", (req, res) => {
  const { username, password } = req.body;
  const sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
  db.query(sql, [username, password], (err) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.json({ ok: false, msg: "Username already exists" });
      }
      return res.json({ ok: false, msg: "Database error" });
    }
    res.json({ ok: true });
  });
});

// 🏠 Get all rooms
app.get("/rooms", (req, res) => {
  db.query("SELECT * FROM rooms", (err, result) => {
    if (err) return res.json({ error: err });
    res.json(result);
  });
});

// 📖 Get all bookings for a specific user
app.get("/bookings/:userId", (req, res) => {
  const { userId } = req.params;
  const sql = `
    SELECT b.id, b.timeslot, b.date, b.status, r.name AS room, r.building
    FROM bookings b
    JOIN rooms r ON b.room_id = r.id
    WHERE b.user_id = ?
    ORDER BY b.id DESC`;
  db.query(sql, [userId], (err, result) => {
    if (err) return res.json({ error: err });
    res.json(result);
  });
});

// ➕ Book a room
app.post("/book", (req, res) => {
  const { userId, roomId, timeslot } = req.body;
  const date = new Date().toISOString().slice(0, 10);

  // Check if user already has active booking
  const checkSql = `SELECT * FROM bookings WHERE user_id = ? AND date = ? AND (status = 'Pending' OR status = 'Approved')`;
  db.query(checkSql, [userId, date], (err, existing) => {
    if (err) return res.json({ ok: false, msg: "Database error" });
    if (existing.length > 0) {
      return res.json({ ok: false, msg: "You already have an active booking today." });
    }

    // Check if timeslot is available
    const slotSql = `SELECT * FROM bookings WHERE room_id = ? AND timeslot = ? AND date = ? AND (status = 'Pending' OR status = 'Approved')`;
    db.query(slotSql, [roomId, timeslot, date], (err, slot) => {
      if (err) return res.json({ ok: false, msg: "Database error" });
      if (slot.length > 0) {
        return res.json({ ok: false, msg: "This time slot is not available." });
      }

      // Insert new booking
      const insertSql = `INSERT INTO bookings (user_id, room_id, timeslot, date, status) VALUES (?, ?, ?, ?, 'Pending')`;
      db.query(insertSql, [userId, roomId, timeslot, date], (err) => {
        if (err) return res.json({ ok: false, msg: "Insert failed" });
        res.json({ ok: true, msg: "Booking request sent!" });
      });
    });
  });
});

// ✅ Server start
app.listen(3000, () => {
  console.log("🚀 Server running on http://172.25.38.173:3000");
});
