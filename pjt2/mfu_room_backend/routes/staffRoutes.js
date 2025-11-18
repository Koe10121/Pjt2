import express from "express";
import db from "../config/db.js";

const router = express.Router();

// ---------------- STAFF: ADD ROOM ----------------
router.post("/staff/rooms", (req, res) => {
  const { name, building } = req.body || {};

  if (!name || !building) {
    return res
      .status(400)
      .json({ ok: false, msg: "Both name and building are required." });
  }

  const sql =
    "INSERT INTO rooms (name, building, is_disabled) VALUES (?, ?, 0)";
  db.query(sql, [name, building], (err, result) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.json({ ok: false, msg: "Room name already exists." });
      }
      console.error("Error inserting room:", err);
      return res
        .status(500)
        .json({ ok: false, msg: "Database error while adding room." });
    }

    return res.json({
      ok: true,
      msg: "Room added successfully.",
      room: {
        id: result.insertId,
        name,
        building,
        disabled: 0
      }
    });
  });
});

// ---------------- STAFF: EDIT ROOM ----------------
router.put("/staff/rooms/:roomId", (req, res) => {
  const { roomId } = req.params;
  const { name, building } = req.body || {};

  if (!name || !building) {
    return res
      .status(400)
      .json({ ok: false, msg: "Both name and building are required." });
  }

  const sql = "UPDATE rooms SET name = ?, building = ? WHERE id = ?";
  db.query(sql, [name, building, roomId], (err, result) => {
    if (err) {
      if (err.code === "ER_DUP_ENTRY") {
        return res.json({ ok: false, msg: "Room name already exists." });
      }
      console.error("Error updating room:", err);
      return res
        .status(500)
        .json({ ok: false, msg: "Database error while updating room." });
    }

    if (result.affectedRows === 0) {
      return res
        .status(404)
        .json({ ok: false, msg: "Room not found for update." });
    }

    return res.json({ ok: true, msg: "Room updated successfully." });
  });
});

// ---------------- STAFF: TOGGLE ROOM DISABLED ----------------
router.post("/staff/rooms/:roomId/toggle-disabled", (req, res) => {
  const { roomId } = req.params;
  const { disabled } = req.body || {};

  if (typeof disabled !== "boolean") {
    return res
      .status(400)
      .json({ ok: false, msg: "Field 'disabled' (boolean) is required." });
  }

  const isDisabled = disabled ? 1 : 0;
  const sql = "UPDATE rooms SET is_disabled = ? WHERE id = ?";
  db.query(sql, [isDisabled, roomId], (err, result) => {
    if (err) {
      console.error("Error toggling room disabled:", err);
      return res
        .status(500)
        .json({ ok: false, msg: "Database error while toggling room." });
    }

    if (result.affectedRows === 0) {
      return res
        .status(404)
        .json({ ok: false, msg: "Room not found for toggle." });
    }

    return res.json({
      ok: true,
      msg: disabled ? "Room disabled successfully." : "Room enabled successfully."
    });
  });
});

export default router;

