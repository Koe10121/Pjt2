import express from "express";
import bcrypt from "bcrypt";
import db from "../config/db.js";

const router = express.Router();

// ---------------- LOGIN ----------------
router.post("/login", (req, res) => {
  const { username, password } = req.body;
  const sql = "SELECT id, username, password, role FROM users WHERE username = ?";

  db.query(sql, [username], async (err, results) => {
    if (err) {
      return res
        .status(500)
        .json({ user: null, msg: "Database error during login." });
    }
    if (results.length === 0) {
      return res.json({ user: null, msg: "Incorrect username or password." });
    }

    const user = results[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.json({ user: null, msg: "Incorrect username or password." });
    }

    delete user.password;

    // Set session
    req.session.user = user;

    return res.json({ user, msg: "Login successful." });
  });
});

// ---------------- LOGOUT ----------------
router.post("/logout", (req, res) => {
  req.session.destroy(err => {
    if (err) {
      return res.status(500).json({ ok: false, msg: "Logout failed." });
    }
    res.clearCookie("session_cookie_name");
    return res.json({ ok: true, msg: "Logout successful." });
  });
});

// ---------------- CHECK SESSION ----------------
router.get("/me", (req, res) => {
  if (req.session.user) {
    return res.json({ ok: true, user: req.session.user });
  }
  return res.json({ ok: false, user: null });
});

// ---------------- REGISTER ----------------
router.post("/register", async (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.json({
      ok: false,
      msg: "Username and password are required."
    });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const sql =
      "INSERT INTO users (username, password, role) VALUES (?, ?, 'student')";
    db.query(sql, [username, hashedPassword], err => {
      if (err) {
        if (err.code === "ER_DUP_ENTRY") {
          return res.json({ ok: false, msg: "Username already exists." });
        }
        return res.json({ ok: false, msg: "Database error." });
      }
      return res.json({
        ok: true,
        msg: "Registration successful (password secured)."
      });
    });
  } catch (err) {
    return res
      .status(500)
      .json({ ok: false, msg: "Server error during registration." });
  }
});

export default router;

