import express from "express";
import db from "../config/db.js";

const router = express.Router();

// ---------------- ROOMS ----------------
router.get("/rooms", (req, res) => {
  db.query(
    "SELECT id, name, building, is_disabled FROM rooms ORDER BY name",
    (err, rows) => {
      if (err) {
        return res.status(500).json({
          error: "db_error",
          msg: "Database error fetching rooms."
        });
      }
      const out = rows.map(r => ({
        id: r.id,
        name: r.name,
        building: r.building,
        disabled: r.is_disabled ? 1 : 0
      }));
      res.json(out);
    }
  );
});

// ---------------- ROOM STATUSES (FOR A GIVEN DATE) ----------------
router.get("/room-statuses/:date", (req, res) => {
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
    if (err) {
      return res.status(500).json({
        error: "db_error",
        msg: "Database error fetching statuses."
      });
    }

    const map = {};
    rows.forEach(row => {
      const rid = row.room_id;
      if (!map[rid]) {
        map[rid] = {
          room_name: row.room_name,
          building: row.building,
          disabled: row.is_disabled ? 1 : 0,
          slots: {
            "8-10": "Free",
            "10-12": "Free",
            "13-15": "Free",
            "15-17": "Free"
          }
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
        map[rid].slots[row.timeslot] = row.status || "Free";
      }
    });
    res.json(map);
  });
});

export default router;

