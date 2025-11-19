// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart'; // Required for Web Cookies

class ApiService {
  // Use localhost for local development to ensure cookies work correctly
  static const base = 'http://localhost:3000';

  // Create a single client instance
  static final http.Client _client = _createClient();

  // Configure client to send cookies (credentials)
  static http.Client _createClient() {
    final client = http.Client();
    if (client is BrowserClient) {
      client.withCredentials = true;
    }
    return client;
  }

  // 🧑‍🏫 Lecturer: get all pending requests
  static Future<List<dynamic>> getLecturerRequests() async {
    try {
      final res = await _client.get(Uri.parse('$base/lecturer/requests'));
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      print('getLecturerRequests error: $e');
      return [];
    }
  }

  // 🧑‍🏫 Lecturer: approve or reject booking
  static Future<Map<String, dynamic>> lecturerAction(
    int lecturerId,
    int bookingId,
    String status,
  ) async {
    try {
      final res = await _client.post(
        Uri.parse('$base/lecturer/action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lecturerId': lecturerId,
          'bookingId': bookingId,
          'status': status,
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      print('lecturerAction error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // 🧑‍🏫 Lecturer: get history
  static Future<List<dynamic>> getLecturerHistory(int lecturerId) async {
    try {
      final res = await _client.get(
        Uri.parse('$base/lecturer/history/$lecturerId'),
      );
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      print('getLecturerHistory error: $e');
      return [];
    }
  }

  // 🧍 LOGIN
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      final res = await _client.post(
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
      final res = await _client.post(
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

  // --------------------------------------------------
  // STAFF: room management
  // --------------------------------------------------

  // Add a new room (name + building).
  static Future<Map<String, dynamic>> staffAddRoom(
    String name,
    String building,
  ) async {
    try {
      final res = await _client.post(
        Uri.parse('$base/staff/rooms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'building': building}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('staffAddRoom error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // Edit an existing room (by id).
  static Future<Map<String, dynamic>> staffEditRoom(
    int roomId,
    String name,
    String building,
  ) async {
    try {
      final res = await _client.put(
        Uri.parse('$base/staff/rooms/$roomId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'building': building}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('staffEditRoom error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // Toggle room disabled flag.
  static Future<Map<String, dynamic>> staffToggleRoomDisabled(
    int roomId,
    bool disabled,
  ) async {
    try {
      final res = await _client.post(
        Uri.parse('$base/staff/rooms/$roomId/toggle-disabled'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'disabled': disabled}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('staffToggleRoomDisabled error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // 🏠 Get all rooms
  static Future<List<dynamic>> getRooms() async {
    try {
      final res = await _client.get(Uri.parse('$base/rooms'));
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
      final res = await _client.get(Uri.parse('$base/bookings/$userId'));
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      print('getBookings error: $e');
      return [];
    }
  }

  // 🧾 Book a room
  static Future<Map<String, dynamic>> bookRoom(
    int userId,
    int roomId,
    String timeslot,
  ) async {
    try {
      final res = await _client.post(
        Uri.parse('$base/book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'roomId': roomId,
          'timeslot': timeslot,
        }),
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
      final res = await _client.get(Uri.parse('$base/room-statuses/$date'));
      if (res.statusCode != 200) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      print('getRoomStatuses error: $e');
      return {};
    }
  }
}
