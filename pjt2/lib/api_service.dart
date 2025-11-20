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
  // Update this if your backend IP/port changes
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

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    token = null;
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
  // AUTH
  // ------------------------------
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
        await saveUser(Map<String, dynamic>.from(user));
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

  // ------------------------------
  // ROOMS / BOOKINGS
  // ------------------------------
  /// Returns List<Map<String,dynamic>>
  static Future<List<Map<String, dynamic>>> getRooms() async {
    try {
      final res = await http.get(Uri.parse('$base/rooms'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      final parsed = jsonDecode(res.body);
      if (parsed is List) {
        return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

  /// room-statuses returns a Map keyed by room id
  static Future<Map<String, dynamic>> getRoomStatuses(String date) async {
    try {
      final res = await http.get(Uri.parse('$base/room-statuses/$date'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {};
    }
  }

  /// returns List<Map<String,dynamic>> for a user's bookings
  static Future<List<Map<String, dynamic>>> getBookings(int userId) async {
    try {
      final res = await http.get(Uri.parse('$base/bookings/$userId'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      final parsed = jsonDecode(res.body);
      if (parsed is List) return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
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
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  // ------------------------------
  // LECTURER endpoints
  // ------------------------------
  static Future<List<Map<String, dynamic>>> getLecturerRequests() async {
    try {
      final res = await http.get(Uri.parse('$base/lecturer/requests'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      final parsed = jsonDecode(res.body);
      if (parsed is List) return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

  static Future<Map<String, dynamic>> lecturerAction(int lecturerId, int bookingId, String status) async {
    try {
      final res = await http.post(
        Uri.parse('$base/lecturer/action'),
        headers: _headers(),
        body: jsonEncode({'lecturerId': lecturerId, 'bookingId': bookingId, 'status': status}),
      );
      _checkAuth(res);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  /// lecturer history for a lecturer id
  static Future<List<Map<String, dynamic>>> getLecturerHistory(int lecturerId) async {
    try {
      final res = await http.get(Uri.parse('$base/lecturer/history/$lecturerId'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      final parsed = jsonDecode(res.body);
      if (parsed is List) return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }

  // ------------------------------
  // STAFF: server-backed room management
  // ------------------------------
  static Future<Map<String, dynamic>> staffAddRoom(String name, String building) async {
    try {
      final res = await http.post(
        Uri.parse('$base/staff/add-room'),
        headers: _headers(),
        body: jsonEncode({'name': name, 'building': building}),
      );
      _checkAuth(res);
      if (res.statusCode != 200) return {'ok': false, 'msg': 'Server error'};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> staffEditRoom(String oldName, String newName, String newBuilding) async {
    try {
      final res = await http.post(
        Uri.parse('$base/staff/edit-room'),
        headers: _headers(),
        body: jsonEncode({'oldName': oldName, 'newName': newName, 'newBuilding': newBuilding}),
      );
      _checkAuth(res);
      if (res.statusCode != 200) return {'ok': false, 'msg': 'Server error'};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> staffToggleRoom(String name, bool disable) async {
    try {
      final res = await http.post(
        Uri.parse('$base/staff/toggle-room'),
        headers: _headers(),
        body: jsonEncode({'name': name, 'disable': disable}),
      );
      _checkAuth(res);
      if (res.statusCode != 200) return {'ok': false, 'msg': 'Server error'};
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return {'ok': false, 'msg': 'Network error'};
    }
  }

  /// Get list of all lecturers (for staff history)
  static Future<List<Map<String, dynamic>>> getAllLecturers() async {
    try {
      final res = await http.get(Uri.parse('$base/staff/all-lecturers'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      final parsed = jsonDecode(res.body);
      if (parsed is List) return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Staff-only: fetch full history of all lecturers (Approved/Rejected)
  static Future<List<Map<String, dynamic>>> getAllLecturerHistoryForStaff() async {
    try {
      final res = await http.get(Uri.parse('$base/staff/all-lecturer-history'), headers: _headers());
      _checkAuth(res);
      if (res.statusCode != 200) return [];
      final parsed = jsonDecode(res.body);
      if (parsed is List) return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      return [];
    }
  }
}
