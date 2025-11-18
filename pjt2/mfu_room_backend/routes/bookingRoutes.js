import express from "express";
import db from "../config/db.js";

const router = express.Router();

// ---------------- BOOKINGS ----------------
router.get("/bookings/:userId", (req, res) => {
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
    if (err) {
      return res.status(500).json({
        error: "db_error",
        msg: "Database error fetching bookings."
      });
    }
    res.json(rows);
  });
});

// ---------------- BOOK ----------------
router.post("/book", (req, res) => {
  const { userId, roomId, timeslot } = req.body;
  const date = new Date().toISOString().slice(0, 10);

  if (!userId || !roomId || !timeslot) {
    return res.json({
      ok: false,
      msg: "Missing userId, roomId, or timeslot."
    });
  }

  const roomCheckSql = "SELECT is_disabled FROM rooms WHERE id = ?";
  db.query(roomCheckSql, [roomId], (err, rows) => {
    if (err) {
      return res.json({
        ok: false,
        msg: "Database error while checking room."
      });
    }
    if (rows.length === 0) {
      return res.json({ ok: false, msg: "Room not found." });
    }

    const isDisabled = rows[0].is_disabled === 1;
    if (isDisabled) {
      return res.json({
        ok: false,
        msg: "This room is currently disabled."
      });
    }

    const [, endHourStr] = timeslot.split("-");
    const endHour = parseInt(endHourStr, 10);

    const now = new Date();
    const utc = now.getTime() + now.getTimezoneOffset() * 60000;
    const thailandTime = new Date(utc + 7 * 3600000);

    const currentHour = thailandTime.getHours();
    const currentMinute = thailandTime.getMinutes();
    const currentTotal = currentHour * 60 + currentMinute;
    const endTotal = endHour * 60;

    if (currentTotal >= endTotal - 30) {
      return res.json({
        ok: false,
        msg: "This time slot has already passed."
      });
    }

    const checkSql = `
      SELECT * FROM bookings
      WHERE user_id = ? AND date = ?
      AND (status = 'Pending' OR status = 'Approved')
    `;
    db.query(checkSql, [userId, date], (err, existing) => {
      if (err) {
        return res.json({ ok: false, msg: "Database error." });
      }
      if (existing.length > 0) {
        return res.json({
          ok: false,
          msg: "You already have an active booking today."
        });
      }

      const slotSql = `
        SELECT * FROM bookings
        WHERE room_id = ? AND timeslot = ? AND date = ?
        AND (status = 'Pending' OR status = 'Approved')
      `;
      db.query(slotSql, [roomId, timeslot, date], (err, slot) => {
        if (err) {
          return res.json({ ok: false, msg: "Database error." });
        }
        if (slot.length > 0) {
          return res.json({
            ok: false,
            msg: "This time slot is not available."
          });
        }

        const insertSql = `
          INSERT INTO bookings (user_id, room_id, timeslot, date, time, status)
          VALUES (?, ?, ?, ?, CURTIME(), 'Pending')
        `;
        db.query(insertSql, [userId, roomId, timeslot, date], err => {
          if (err) {
            return res.json({ ok: false, msg: "Insert failed." });
          }
          res.json({ ok: true, msg: "Booking request sent!" });
        });
      });
    });
  });
});

export default router;

