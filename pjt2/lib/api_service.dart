// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Simple exception type to indicate 401 from the API.
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = "Unauthorized"]);
  @override
  String toString() => "UnauthorizedException: $message";
}

class ApiService {
  static const base = 'http://192.168.1.105:3000';

  // runtime token memory
  static String? token;

  // ------------------------------
  // TOKEN + USER LOCAL STORAGE
  // ------------------------------
  static Future<void> saveToken(String t) async {
    final prefs = await SharedPreferences.getInstance();
    token = t;
    await prefs.setString("token", t);
  }

  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("user", jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString("user");
    if (str == null) return null;
    return jsonDecode(str) as Map<String, dynamic>;
  }

  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
    return token;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    token = null;
  }

  // ------------------------------
  // Headers + Unauthorized checks
  // ------------------------------

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

  // ------------------------------
  // API CALLS
  // ------------------------------

  static Future<List<dynamic>> getLecturerRequests() async {
    try {
      final res = await http.get(Uri.parse('$base/lecturer/requests'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

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
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  static Future<List<dynamic>> getLecturerHistory(int lecturerId) async {
    try {
      final res =
          await http.get(Uri.parse('$base/lecturer/history/$lecturerId'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

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
      final t = data['token'];

      if (user != null && t != null) {
        await saveUser(user);
        await saveToken(t);
      }

      return user != null ? Map<String, dynamic>.from(user) : null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> register(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode != 200) return false;
      return jsonDecode(res.body)['ok'] == true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<dynamic>> getRooms() async {
    try {
      final res = await http.get(Uri.parse('$base/rooms'), headers: _headers());
      _checkAuth(res);
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

  static Future<List<dynamic>> getBookings(int userId) async {
    try {
      final res = await http.get(Uri.parse('$base/bookings/$userId'), headers: _headers());
      _checkAuth(res);
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

  static Future<Map<String, dynamic>> bookRoom(int userId, int roomId, String timeslot) async {
    try {
      final res = await http.post(
        Uri.parse('$base/book'),
        headers: _headers(),
        body: jsonEncode({'userId': userId, 'roomId': roomId, 'timeslot': timeslot}),
      );
      _checkAuth(res);
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> getRoomStatuses(String date) async {
    try {
      final res =
          await http.get(Uri.parse('$base/room-statuses/$date'), headers: _headers());
      _checkAuth(res);
      return jsonDecode(res.body);
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {};
    }
  }
}
