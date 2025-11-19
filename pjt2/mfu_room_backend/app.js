import express from "express";
import cors from "cors";
import bodyParser from "body-parser";
import session from "express-session";
import MySQLStore from "express-mysql-session";
import db from "./config/db.js"; // Import db connection to use with session store

import authRoutes from "./routes/authRoutes.js";
import roomRoutes from "./routes/roomRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import lecturerRoutes from "./routes/lecturerRoutes.js";
import staffRoutes from "./routes/staffRoutes.js";

const app = express();

// Session Store Options
const sessionStore = new (MySQLStore(session))({}, db);

app.use(
  cors({
    origin: "http://localhost:5173", // Replace with your frontend URL
    credentials: true
  })
);
app.use(bodyParser.json());

// Session Middleware
app.use(
  session({
    key: "session_cookie_name",
    secret: "session_cookie_secret", // Change this to a secure secret in production
    store: sessionStore,
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: false, // Set to true if using HTTPS
      httpOnly: true,
      maxAge: 1000 * 60 * 60 * 24 // 1 day
    }
  })
);

app.get("/", (req, res) =>
  res.send("MFU Room Reservation Backend is running!")
);

// Routes
app.use("/", authRoutes);
app.use("/", roomRoutes);
app.use("/", bookingRoutes);
app.use("/", lecturerRoutes);
app.use("/", staffRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
