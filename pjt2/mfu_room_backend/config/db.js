import mysql from "mysql2";

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "mfu_rooms_pj"
});

db.connect(err => {
  if (err) {
    console.log("❌ Database connection failed:", err);
    process.exit(1);
  } else {
    console.log("✅ Connected to MySQL database: mfu_rooms_pj");
  }
});

export default db;

