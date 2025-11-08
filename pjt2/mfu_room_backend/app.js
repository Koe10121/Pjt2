// app.js
import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import mysql from "mysql2";

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
  const sql = "SELECT id, username, role FROM users WHERE username = ? AND password = ?";
  db.query(sql, [username, password], (err, result) => {
    if (err) return res.status(500).json({ user: null, msg: "Database error during login." });
    if (result.length > 0) return res.json({ user: result[0], msg: "Login successful." });
    return res.json({ user: null, msg: "Incorrect username or password." });
  });
});

// ---------------- REGISTER ----------------
app.post("/register", (req, res) => {
  const { username, password } = req.body;
  const sql = "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
  db.query(sql, [username, password], (err) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") return res.json({ ok: false, msg: "Username already exists." });
      return res.json({ ok: false, msg: "username already exist" });
    }
    return res.json({ ok: true, msg: "Registration successful." });
  });
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
    // ⚠️ Do NOT wrap, return plain array like before (so UI still works)
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
    // ⚠️ UI expects an array directly
    res.json(rows);
  });
});

// ---------------- BOOK ----------------
// ---------------- BOOK ----------------
app.post("/book", (req, res) => {
  const { userId, roomId, timeslot } = req.body;
  const date = new Date().toISOString().slice(0, 10);

  if (!userId || !roomId || !timeslot) {
    return res.json({ ok: false, msg: "Missing userId, roomId, or timeslot." });
  }

  // ✅ Step 1: Check if the room is disabled
  const roomCheckSql = "SELECT is_disabled FROM rooms WHERE id = ?";
  db.query(roomCheckSql, [roomId], (err, rows) => {
    if (err) return res.json({ ok: false, msg: "Database error while checking room." });
    if (rows.length === 0) return res.json({ ok: false, msg: "Room not found." });

    const isDisabled = rows[0].is_disabled === 1;
    if (isDisabled) {
      return res.json({ ok: false, msg: "This room is currently disabled." });
    }

    // ✅ Step 2: Time validation
    const [_, endHourStr] = timeslot.split("-");
    const endHour = parseInt(endHourStr);

    const now = new Date();
    const utc = now.getTime() + now.getTimezoneOffset() * 60000;
    const thailandTime = new Date(utc + 7 * 3600000);

    const currentHour = thailandTime.getHours();
    const currentMinute = thailandTime.getMinutes();
    const currentTotal = currentHour * 60 + currentMinute;
    const endTotal = endHour * 60;

    if (currentTotal >= endTotal-30)
      return res.json({ ok: false, msg: "This time slot has already passed." });

    // ✅ Step 3: Check if user already has an active booking
    const checkSql = `
      SELECT * FROM bookings
      WHERE user_id = ? AND date = ?
      AND (status = 'Pending' OR status = 'Approved')
    `;
    db.query(checkSql, [userId, date], (err, existing) => {
      if (err) return res.json({ ok: false, msg: "Database error." });
      if (existing.length > 0)
        return res.json({ ok: false, msg: "You already have an active booking today." });

      // ✅ Step 4: Check if slot already booked
      const slotSql = `
        SELECT * FROM bookings
        WHERE room_id = ? AND timeslot = ? AND date = ?
        AND (status = 'Pending' OR status = 'Approved')
      `;
      db.query(slotSql, [roomId, timeslot, date], (err, slot) => {
        if (err) return res.json({ ok: false, msg: "Database error." });
        if (slot.length > 0)
          return res.json({ ok: false, msg: "This time slot is not available." });

        // ✅ Step 5: Insert booking
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


// ---------------- ROOM STATUSES ----------------
app.get("/room-statuses/:date", (req, res) => {
  const date = req.params.date;
  const sql = `
    SELECT r.id AS room_id, r.name AS room_name, b.timeslot, b.status
    FROM rooms r
    LEFT JOIN bookings b ON r.id = b.room_id AND b.date = ?
    ORDER BY r.id
  `;
  db.query(sql, [date], (err, rows) => {
    if (err) return res.status(500).json({ error: "db_error", msg: "Database error fetching statuses." });
    const map = {};
    rows.forEach(row => {
      const rid = row.room_id;
      if (!map[rid]) map[rid] = {};
      if (row.timeslot) map[rid][row.timeslot] = row.status;
    });
    // ⚠️ UI expects plain map
    res.json(map);
  });
});

// =============== STAFF ROOM MANAGEMENT ENDPOINTS ===============

// ➕ ADD NEW ROOM
app.post("/staff/rooms", (req, res) => {
  const { name, building } = req.body;

  if (!name || !building) {
    return res.status(400).json({ message: "Room name and building are required" });
  }

  const sql = "INSERT INTO rooms (name, building, is_disabled) VALUES (?, ?, 0)";
  
  db.query(sql, [name, building], (err, result) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.status(400).json({ message: "Room name already exists" });
      }
      console.log("Add room error:", err);
      return res.status(500).json({ message: "Database error while adding room" });
    }

    res.status(201).json({
      id: result.insertId,
      name: name,
      building: building,
      is_disabled: 0
    });
  });
});

// ✏️ EDIT ROOM
app.put("/staff/rooms/:id", (req, res) => {
  const roomId = req.params.id;
  const { name, building } = req.body;

  if (!name || !building) {
    return res.status(400).json({ message: "Room name and building are required" });
  }

  const checkSql = "SELECT id FROM rooms WHERE id = ?";
  db.query(checkSql, [roomId], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: "Database error" });
    }
    
    if (rows.length === 0) {
      return res.status(404).json({ message: "Room not found" });
    }

    const updateSql = "UPDATE rooms SET name = ?, building = ? WHERE id = ?";
    db.query(updateSql, [name, building, roomId], (err, result) => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.status(400).json({ message: "Room name already exists" });
        }
        return res.status(500).json({ message: "Database error while updating room" });
      }

      res.json({
        id: parseInt(roomId),
        name: name,
        building: building
      });
    });
  });
});

// 🔄 TOGGLE ROOM STATUS (Enable/Disable)
app.patch("/staff/rooms/:id/status", (req, res) => {
  const roomId = req.params.id;
  const { isDisabled } = req.body;

  if (typeof isDisabled !== 'boolean') {
    return res.status(400).json({ message: "isDisabled must be a boolean" });
  }

  const checkSql = "SELECT id FROM rooms WHERE id = ?";
  db.query(checkSql, [roomId], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: "Database error" });
    }
    
    if (rows.length === 0) {
      return res.status(404).json({ message: "Room not found" });
    }

    const updateSql = "UPDATE rooms SET is_disabled = ? WHERE id = ?";
    db.query(updateSql, [isDisabled ? 1 : 0, roomId], (err, result) => {
      if (err) {
        return res.status(500).json({ message: "Database error while updating room status" });
      }

      res.json({
        id: parseInt(roomId),
        is_disabled: isDisabled ? 1 : 0
      });
    });
  });
});

// 🗑️ DELETE ROOM
app.delete("/staff/rooms/:id", (req, res) => {
  const roomId = req.params.id;

  const checkSql = "SELECT id FROM rooms WHERE id = ?";
  db.query(checkSql, [roomId], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: "Database error" });
    }
    
    if (rows.length === 0) {
      return res.status(404).json({ message: "Room not found" });
    }

    const deleteSql = "DELETE FROM rooms WHERE id = ?";
    db.query(deleteSql, [roomId], (err, result) => {
      if (err) {
        return res.status(500).json({ message: "Database error while deleting room" });
      }

      res.json({ 
        message: "Room deleted successfully"
      });
    });
  });
});


const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
