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

    // Calculate current time in Thailand
    const now = new Date();
    const utc = now.getTime() + now.getTimezoneOffset() * 60000;
    const thailandTime = new Date(utc + 7 * 3600000);
    const currentHour = thailandTime.getHours();
    const currentMinute = thailandTime.getMinutes();
    const currentTotal = currentHour * 60 + currentMinute;
    const todayStr = thailandTime.toISOString().slice(0, 10);

    const isToday = date === todayStr;

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

      // If room is disabled, all slots are disabled
      if (row.is_disabled === 1) {
        map[rid].slots = {
          "8-10": "Disabled",
          "10-12": "Disabled",
          "13-15": "Disabled",
          "15-17": "Disabled"
        };
      } else {
        // Apply booking status
        if (row.timeslot) {
          map[rid].slots[row.timeslot] = row.status || "Free";
        }

        // Check for passed slots (only if it's today)
        if (isToday) {
          for (const [slot, status] of Object.entries(map[rid].slots)) {
            if (status === "Free") {
              const [, endHourStr] = slot.split("-");
              const endHour = parseInt(endHourStr, 10);
              const endTotal = endHour * 60;

              // If current time is past the slot end time (minus 30 mins buffer if you want, or strict)
              // User said "if the time of that slots pass dont count it"
              // Let's use strict end time or the same logic as booking (end - 30 mins)
              // Booking logic: if (currentTotal >= endTotal - 30) -> passed
              if (currentTotal >= endTotal - 30) {
                map[rid].slots[slot] = "Passed";
              }
            }
          }
        }
      }
    });
    res.json(map);
  });
});

export default router;

