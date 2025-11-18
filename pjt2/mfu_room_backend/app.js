import express from "express";
import cors from "cors";
import bodyParser from "body-parser";

import authRoutes from "./routes/authRoutes.js";
import roomRoutes from "./routes/roomRoutes.js";
import bookingRoutes from "./routes/bookingRoutes.js";
import lecturerRoutes from "./routes/lecturerRoutes.js";
import staffRoutes from "./routes/staffRoutes.js";

const app = express();

app.use(cors());
app.use(bodyParser.json());

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
