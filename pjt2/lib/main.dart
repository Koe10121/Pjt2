// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pjt2/student/student_home.dart';
import 'package:pjt2/lecturer/lecturer_home.dart';
import 'package:pjt2/staff/staff_home.dart';
import 'api_service.dart';

class AppData {
  static Map<String, dynamic>? currentUser;

  static String get todayDate {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static String nowTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // logout helper used across the app (fixed: does not rely on '/' route)
  static void performLogout(BuildContext context) {
    ApiService.clearAll();
    currentUser = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // check if student already has booking today (Pending or Approved)
  static Future<bool> hasActiveBookingToday(int userId) async {
    final bookings = await ApiService.getBookings(userId);
    return bookings.any(
      (b) =>
          (b['date'] ?? '') == todayDate &&
          ((b['status'] ?? '') == 'Pending' || (b['status'] ?? '') == 'Approved'),
    );
  }

  // --------------------------------------------------
  // SHARED STATE (rooms, statuses, etc.)
  // --------------------------------------------------
  static Map<String, Map<String, String>> slotStatus = {};
  static Map<String, String> roomBuildings = {};
  static Map<String, int> roomNameToId = {};

  static List<Map<String, dynamic>> lecturerRequests = [];
  static List<Map<String, dynamic>> lecturerHistory = [];
  static List<Map<String, dynamic>> staffHistory = [];

  // Load rooms + today's statuses and fill caches
  static Future<void> loadRoomData() async {
    final rooms = await ApiService.getRooms();
    slotStatus.clear();
    roomBuildings.clear();
    roomNameToId.clear();

    for (var r in rooms) {
      final name = r['name']?.toString() ?? '';
      final building = r['building']?.toString() ?? '';
      final id = r['id'] is int ? r['id'] as int : int.tryParse(r['id'].toString()) ?? 0;
      roomBuildings[name] = building;
      roomNameToId[name] = id;
      slotStatus[name] = {
        '8-10': 'Free',
        '10-12': 'Free',
        '13-15': 'Free',
        '15-17': 'Free',
      };
      if ((r['disabled'] ?? 0) == 1) {
        slotStatus[name]!.updateAll((k, v) => 'Disabled');
      }
    }

    final statuses = await ApiService.getRoomStatuses(AppData.todayDate);
    try {
      if (statuses is Map) {
        statuses.forEach((roomId, data) {
          if (data is Map && data['room_name'] != null && data['slots'] != null) {
            final rname = data['room_name'];
            final m = slotStatus[rname];
            if (m != null) {
              final disabled = data['disabled'] == 1;
              if (disabled) {
                m.updateAll((key, value) => 'Disabled');
              } else {
                final slots = Map<String, dynamic>.from(data['slots']);
                slots.forEach((slot, status) {
                  m[slot] = status ?? 'Free';
                });
              }
            }
          }
        });
      }
    } catch (e) {
      print("loadRoomData status merge error: $e");
    }
  }

  // Lecturer action (approve/reject) — updates local caches
  static Future<void> lecturerAction(BuildContext context, int idx, String status) async {
    if (idx < 0 || idx >= lecturerRequests.length) return;

    final req = lecturerRequests[idx];
    final bookingId = req['id'];
    final lecturerId = currentUser?['id'] ?? 0;

    try {
      final result = await ApiService.lecturerAction(lecturerId, bookingId, status);
      if (result['ok'] == true) {
        final record = {...req, 'status': status, 'actionTime': DateTime.now().toString().substring(11, 16)};

        try {
          final roomName = req['room'];
          final timeslot = req['timeslot'];
          if (roomName != null && timeslot != null) {
            final map = slotStatus[roomName];
            if (map != null) {
              if (status == 'Approved') {
                map[timeslot] = 'Approved';
              } else if (status == 'Rejected') {
                map[timeslot] = 'Free';
              }
            }
          }
        } catch (e) {
          print('Error updating slotStatus after lecturerAction: $e');
        }

        lecturerHistory.insert(0, record);
        lecturerRequests.removeAt(idx);
      } else {
        print('lecturerAction response: ${result['msg']}');
      }
    } catch (e) {
      print('Error performing lecturerAction: $e');
    }
  }

  // ---------------- STAFF helpers that update local cache ----------------
  static Future<Map<String, dynamic>> staffAddRoom(String name, String building) async {
    try {
      final resp = await ApiService.staffAddRoom(name, building);
      if (resp['ok'] == true) {
        // backend returns id; reload room data to be safe
        await loadRoomData();
      }
      return resp;
    } catch (e) {
      print("staffAddRoom error: $e");
      return {'ok': false, 'msg': 'Error'};
    }
  }

  static Future<Map<String, dynamic>> staffEditRoom(String oldName, String oldBuilding, String newName, String newBuilding) async {
    try {
      final resp = await ApiService.staffEditRoom(oldName, oldBuilding, newName, newBuilding);
      if (resp['ok'] == true) {
        await loadRoomData();
      }
      return resp;
    } catch (e) {
      print("staffEditRoom error: $e");
      return {'ok': false, 'msg': 'Error'};
    }
  }

  static Future<Map<String, dynamic>> staffToggleRoomDisabled(String roomName, String building, bool disable) async {
    try {
      final resp = await ApiService.staffToggleRoom(name: roomName, building: building, disable: disable);
      if (resp['ok'] == true) {
        await loadRoomData();
      }
      return resp;
    } catch (e) {
      print("staffToggleRoomDisabled error: $e");
      return {'ok': false, 'msg': 'Error'};
    }
  }

  // --------------------------------------------------
  // STAFF: Load ALL lecturer history (for staff)
  // This collects every lecturer's history (all days).
  // --------------------------------------------------
  static Future<void> loadAllLecturerHistoryForStaff() async {
    try {
      // Use the staff-specific endpoint that returns all lecturers' history
      final all = await ApiService.getAllLecturerHistoryForStaff();
      // Ensure all entries are proper Map<String,dynamic>
      staffHistory = all.map((e) => Map<String, dynamic>.from(e)).toList();
      // Sort by date then time descending
      staffHistory.sort((a, b) {
        final da = a['date'] ?? '';
        final db = b['date'] ?? '';
        if (da == db) {
          return (b['time'] ?? '').compareTo(a['time'] ?? '');
        }
        return (db as String).compareTo(da as String);
      });
    } catch (e) {
      print("loadAllLecturerHistoryForStaff error: $e");
      staffHistory = [];
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved token & user before app runs
  final loadedToken = await ApiService.loadToken();
  final loadedUser = await ApiService.loadUser();

  if (loadedToken != null && loadedUser != null) {
    AppData.currentUser = loadedUser;
    // pre-load room data so pages show correctly when opened
    await AppData.loadRoomData();
    // staff specific: preload lecturer history if staff
    if ((loadedUser['role'] ?? '') == 'staff') {
      await AppData.loadAllLecturerHistoryForStaff();
    } else if ((loadedUser['role'] ?? '') == 'lecturer') {
      // lecturer: preload today's requests
      try {
        AppData.lecturerRequests = await ApiService.getLecturerRequests();
      } catch (_) {}
    }
  }

  runApp(MyApp(autoUser: loadedUser));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic>? autoUser;
  const MyApp({super.key, required this.autoUser});

  @override
  Widget build(BuildContext context) {
    Widget startPage;

    if (autoUser == null) {
      // no saved login
      startPage = const LoginPage();
    } else {
      final role = (autoUser!['role'] ?? '').toString();
      if (role == 'student') {
        startPage = StudentHomePage(
          userId: autoUser!['id'],
          username: autoUser!['username'],
        );
      } else if (role == 'lecturer') {
        startPage = const LecturerHomePage();
      } else if (role == 'staff') {
        startPage = const StaffHomePage();
      } else {
        startPage = const LoginPage();
      }
    }

    return MaterialApp(
      title: 'MFU Room Reservation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: startPage,
      // keep a route for register to use pushNamed
      routes: {'/register': (_) => const RegisterPage()},
    );
  }
}

// ------------------------------------------------------
// LOGIN PAGE
// (Minimal, same behavior as your existing UI; keep your existing UI files as-is)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> _tryLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter username and password")));
      return;
    }
    setState(() => loading = true);
    final user = await ApiService.login(username, password);
    setState(() => loading = false);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Invalid login")));
      return;
    }
    AppData.currentUser = user;
    final role = (user['role'] ?? '').toString();
    if (role == 'student') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudentHomePage(userId: user['id'], username: user['username'])));
    } else if (role == 'lecturer') {
      // load lecturer requests
      AppData.lecturerRequests = await ApiService.getLecturerRequests();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LecturerHomePage()));
    } else if (role == 'staff') {
      await AppData.loadRoomData();
      await AppData.loadAllLecturerHistoryForStaff();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const StaffHomePage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Role not allowed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep your previous login UI; simplified here (works driver code)
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(children: [
                Icon(Icons.meeting_room, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text('MFU Room Reservation', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text('Login to continue', style: TextStyle(color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))]),
              child: Column(children: [
                TextField(controller: _usernameCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), labelText: 'Username', border: OutlineInputBorder())),
                const SizedBox(height: 15),
                TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'Password', border: OutlineInputBorder())),
                const SizedBox(height: 20),
                SizedBox(width: double.infinity, height: 45, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: loading ? null : _tryLogin, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign In', style: TextStyle(fontSize: 16, color: Colors.white)))),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/register'), child: const Text("Create new account", style: TextStyle(color: Colors.indigo))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// REGISTER PAGE (unchanged)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool loading = false;

  Future<void> _register() async {
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    final c = _confirmCtrl.text;
    if (u.isEmpty || p.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    if (p != c) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }
    setState(() => loading = true);
    final ok = await ApiService.register(u, p);
    setState(() => loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration successful!")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Username exists or server error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 40),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)]), borderRadius: BorderRadius.circular(20)),
              child: const Column(children: [Icon(Icons.person_add_alt_1, color: Colors.white, size: 60), SizedBox(height: 10), Text('Student Registration', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('Create your student account', style: TextStyle(color: Colors.white70))]),
            ),
            const SizedBox(height: 30),
            Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 8, offset: Offset(0, 4))]), child: Column(children: [
              TextField(controller: _usernameCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline), labelText: 'Username', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: _passwordCtrl, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline), labelText: 'Password', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Confirm Password', border: OutlineInputBorder())),
              const SizedBox(height: 20),
              SizedBox(width: double.infinity, height: 45, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: loading ? null : _register, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Register', style: TextStyle(fontSize: 16, color: Colors.white)))),
              const SizedBox(height: 10),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back to Login", style: TextStyle(color: Colors.indigo))),
            ])),
          ]),
        ),
      ),
    );
  }
}
