// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // ✅ CHANGE THIS depending on your setup:
  // Android emulator -> 'http://10.0.2.2:3000'
  // iOS simulator    -> 'http://localhost:3000'
  // Real phone       -> 'http://<your-PC-IP>:3000'
  static const base = 'http://192.168.1.105:3000';

  // 🧍 LOGIN
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$base/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final user = data['user'];
      return user != null ? Map<String, dynamic>.from(user) : null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // 📝 REGISTER (student only)
  static Future<bool> register(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode != 200) return false;
      final data = jsonDecode(res.body);
      return data['ok'] == true;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  // 🏠 Get all rooms
  static Future<List<dynamic>> getRooms() async {
    try {
      final res = await http.get(Uri.parse('$base/rooms'));
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      print('getRooms error: $e');
      return [];
    }
  }

  // 📖 Get all bookings for a specific user
  static Future<List<dynamic>> getBookings(int userId) async {
    try {
      final res = await http.get(Uri.parse('$base/bookings/$userId'));
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      print('getBookings error: $e');
      return [];
    }
  }

  // 🧾 Book a room
  static Future<Map<String, dynamic>> bookRoom(int userId, int roomId, String timeslot) async {
    try {
      final res = await http.post(
        Uri.parse('$base/book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'roomId': roomId, 'timeslot': timeslot}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('bookRoom error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // 🕒 NEW: Get room statuses (for showing Pending / Approved / Free)
  static Future<Map<String, dynamic>> getRoomStatuses(String date) async {
    try {
      final res = await http.get(Uri.parse('$base/room-statuses/$date'));
      if (res.statusCode != 200) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('getRoomStatuses error: $e');
      return {};
    }
  }
}
