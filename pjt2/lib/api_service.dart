// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple exception type to indicate 401 from the API.
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "Unauthorized"]);
  @override
  String toString() => "UnauthorizedException: $message";
}

class ApiService {
  static const base = 'http://192.168.1.105:3000';

  // stored token after login
  static String? token;

  // helper to build headers (includes token if available)
  static Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (token != null) h['Authorization'] = 'Bearer $token';
    return h;
  }

  static void _checkAuth(http.Response res) {
    if (res.statusCode == 401) {
      throw UnauthorizedException();
    }
  }

  // 🧑‍🏫 Lecturer: get all pending requests (requires token)
  static Future<List<dynamic>> getLecturerRequests() async {
    try {
      final res =
          await http.get(Uri.parse('$base/lecturer/requests'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('getLecturerRequests error: $e');
      return [];
    }
  }

  // 🧑‍🏫 Lecturer: approve or reject booking
  static Future<Map<String, dynamic>> lecturerAction(
      int lecturerId, int bookingId, String status) async {
    try {
      final res = await http.post(
        Uri.parse('$base/lecturer/action'),
        headers: _headers(),
        body: jsonEncode({
          'lecturerId': lecturerId,
          'bookingId': bookingId,
          'status': status,
        }),
      );
      _checkAuth(res);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('lecturerAction error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // 🧑‍🏫 Lecturer: get history
  static Future<List<dynamic>> getLecturerHistory(int lecturerId) async {
    try {
      final res = await http.get(
          Uri.parse('$base/lecturer/history/$lecturerId'),
          headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('getLecturerHistory error: $e');
      return [];
    }
  }

  // 🧍 LOGIN (now saves token)
  // Returns the user map on success, null on failure
  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$base/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final user = data['user'];
      final tok = data['token'];
      if (tok != null) token = tok as String;
      return user != null ? Map<String, dynamic>.from(user) : null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // 📝 REGISTER (student only) — stays open
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

  // 🏠 Get all rooms (authenticated)
  static Future<List<dynamic>> getRooms() async {
    try {
      final res = await http.get(Uri.parse('$base/rooms'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('getRooms error: $e');
      return [];
    }
  }

  // 📖 Get all bookings for a specific user (authenticated)
  static Future<List<dynamic>> getBookings(int userId) async {
    try {
      final res =
          await http.get(Uri.parse('$base/bookings/$userId'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body) as List<dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('getBookings error: $e');
      return [];
    }
  }

  // 🧾 Book a room (authenticated)
  static Future<Map<String, dynamic>> bookRoom(
      int userId, int roomId, String timeslot) async {
    try {
      final res = await http.post(
        Uri.parse('$base/book'),
        headers: _headers(),
        body: jsonEncode({'userId': userId, 'roomId': roomId, 'timeslot': timeslot}),
      );
      _checkAuth(res);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('bookRoom error: $e');
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // 🕒 Get room statuses for a date (authenticated)
  static Future<Map<String, dynamic>> getRoomStatuses(String date) async {
    try {
      final res =
          await http.get(Uri.parse('$base/room-statuses/$date'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      print('getRoomStatuses error: $e');
      return {};
    }
  }

  // Simple helper to clear token client-side (you can call this on logout)
  static void clearToken() {
    token = null;
  }
}
