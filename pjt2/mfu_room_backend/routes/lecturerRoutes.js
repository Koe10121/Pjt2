import express from "express";
import db from "../config/db.js";
import { isAuthenticated } from "../middleware/authMiddleware.js";

const router = express.Router();

// Apply middleware to all routes in this file
router.use(isAuthenticated);

// ---------------- LECTURER: GET TODAY'S PENDING REQUESTS ----------------
router.get("/lecturer/requests", (req, res) => {
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
      return res.status(500).json({
        ok: false,
        msg: "Database error fetching today's pending requests."
      });
    }
    res.json(rows);
  });
});

// ---------------- LECTURER: APPROVE or REJECT REQUEST ----------------
router.post("/lecturer/action", (req, res) => {
  const { lecturerId, bookingId, status } = req.body;

  if (!lecturerId || !bookingId || !status) {
    return res.json({
      ok: false,
      msg: "Missing lecturerId, bookingId, or status."
    });
  }

  if (!["Approved", "Rejected"].includes(status)) {
    return res.json({ ok: false, msg: "Invalid status value." });
  }

  const checkLecturerSql = "SELECT role FROM users WHERE id = ?";
  db.query(checkLecturerSql, [lecturerId], (err, rows) => {
    if (err) {
      return res.json({
        ok: false,
        msg: "Database error (lecturer check)."
      });
    }
    if (rows.length === 0) {
      return res.json({ ok: false, msg: "Lecturer not found." });
    }

    if (rows[0].role !== "lecturer") {
      return res.json({
        ok: false,
        msg: "Only lecturers can approve or reject."
      });
    }

    const checkBookingSql = `
      SELECT * FROM bookings
      WHERE id = ? AND DATE(date) = CURDATE()
    `;
    db.query(checkBookingSql, [bookingId], (err, bookingRows) => {
      if (err) {
        return res.json({
          ok: false,
          msg: "Database error (booking check)."
        });
      }
      if (bookingRows.length === 0) {
        return res.json({
          ok: false,
          msg: "Booking not found or not from today."
        });
      }

      const booking = bookingRows[0];

      if (booking.status !== "Pending") {
        return res.json({
          ok: false,
          msg: "This booking is already processed."
        });
      }

      const updateSql = `
        UPDATE bookings
        SET status = ?, action_by = ?, time = CURTIME()
        WHERE id = ?
      `;
      db.query(updateSql, [status, lecturerId, bookingId], err => {
        if (err) {
          return res.json({ ok: false, msg: "Error updating booking." });
        }
        return res.json({
          ok: true,
          msg: `Booking ${status} successfully.`
        });
      });
    });
  });
});

// ---------------- LECTURER: HISTORY ----------------
router.get("/lecturer/history/:lecturerId", (req, res) => {
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
      return res.status(500).json({
        ok: false,
        msg: "Database error fetching lecturer history."
      });
    }
    res.json(rows);
  });
});

export default router;

