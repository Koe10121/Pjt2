import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const base = 'http://172.25.38.173:3000';

  static Future<Map<String, dynamic>?> login(String username, String password) async {
    final res = await http.post(Uri.parse('$base/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    return data is Map<String, dynamic> ? data : null;
  }

  static Future<bool> register(String username, String password) async {
    final res = await http.post(Uri.parse('$base/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode != 200) return false;
    final data = jsonDecode(res.body);
    return data['ok'] == true;
  }

  static Future<List<dynamic>> getRooms() async {
    final res = await http.get(Uri.parse('$base/rooms'));
    if (res.statusCode != 200) return [];
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getBookings(int userId) async {
    final res = await http.get(Uri.parse('$base/bookings/$userId'));
    if (res.statusCode != 200) return [];
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> bookRoom(int userId, int roomId, String timeslot) async {
    final res = await http.post(Uri.parse('$base/book'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'roomId': roomId, 'timeslot': timeslot}));
    return jsonDecode(res.body);
  }
}
