// lib/main.dart
import 'package:flutter/material.dart';
import 'package:pjt2/student/student_home.dart';
import 'package:pjt2/lecturer/lecturer_home.dart'; // ✅ make sure import path matches
import 'api_service.dart';

class AppData {
  // 👤 logged-in user (student or lecturer)
  static Map<String, dynamic>? currentUser;

  // 🕓 common utils
  static String get todayDate {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static String nowTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // logout helper used across the app
 static void performLogout(BuildContext context) {
  ApiService.clearAll();   // <-- FIXED
  AppData.currentUser = null;
  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
}


  // 🧾 (student) check if has booking today
  static Future<bool> hasActiveBookingToday(int userId) async {
    final bookings = await ApiService.getBookings(userId);
    return bookings.any(
      (b) =>
          (b['date'] ?? '') == todayDate &&
          ((b['status'] ?? '') == 'Pending' ||
              (b['status'] ?? '') == 'Approved'),
    );
  }

  // --------------------------------------------------
  // LECTURER SHARED STATE (for your lecturer pages)
  // --------------------------------------------------

  // rooms status cache for lecturer browse page
  // e.g. { "A101": { "8-10": "Free", "10-12": "Pending" } }
  static Map<String, Map<String, String>> slotStatus = {};
  // room -> building
  static Map<String, String> roomBuildings = {};

  // pending requests that lecturer can approve/reject
  static List<Map<String, dynamic>> lecturerRequests = [];

  // history of actions (approve/reject)
  static List<Map<String, dynamic>> lecturerHistory = [];

  // this is the function your lecturer requests page was calling
  // it now accepts BuildContext to allow logout handling
 static Future<void> lecturerAction(
    BuildContext context, int idx, String status) async {
  if (idx < 0 || idx >= lecturerRequests.length) return;

  final req = lecturerRequests[idx];
  final bookingId = req['id'];
  final lecturerId = currentUser?['id'] ?? 0;

  try {
    final result = await ApiService.lecturerAction(
      lecturerId,
      bookingId,
      status,
    );

    if (result['ok'] == true) {
      // update slot
      try {
        final room = req['room'];
        final slot = req['timeslot'];
        if (room != null && slot != null) {
          if (status == 'Approved') {
            AppData.slotStatus[room]?[slot] = 'Approved';
          } else {
            AppData.slotStatus[room]?[slot] = 'Free';
          }
        }
      } catch (_) {}

      // add to history
      lecturerHistory.insert(0, {
        ...req,
        "status": status,
        "actionTime": DateTime.now().toString().substring(11, 16),
      });

      // remove from pending
      lecturerRequests.removeAt(idx);
    }
  } on UnauthorizedException {
    performLogout(context);
  } catch (e) {
    print("lecturerAction error: $e");
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
  }

  runApp(MyApp(
    autoUser: loadedUser,
  ));
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
      if (autoUser!['role'] == 'student') {
        startPage = StudentHomePage(
          userId: autoUser!['id'],
          username: autoUser!['username'],
        );
      } else {
        startPage = const LecturerHomePage();
      }
    }

    return MaterialApp(
      title: 'MFU Room Reservation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: startPage,
      routes: {'/register': (_) => const RegisterPage()},
    );
  }
}




// ------------------------------------------------------
// LOGIN PAGE (same UI as yours)
// ------------------------------------------------------
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool loading = false;

  Future<void> _showMsg(String text) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _tryLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (username.isEmpty || password.isEmpty) {
      _showMsg("Enter username and password");
      return;
    }
    setState(() => loading = true);
    final user = await ApiService.login(username, password);
    setState(() => loading = false);

    if (user == null) {
      _showMsg("Invalid username or password");
      return;
    }

    // ✅ save globally
    AppData.currentUser = user;

    // ✅ route by role
    if (user['role'] == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentHomePage(
            userId: user['id'] as int,
            username: user['username'] as String,
          ),
        ),
      );
    } else if (user['role'] == 'lecturer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LecturerHomePage(),
        ),
      );
    } else {
      _showMsg("This role is not allowed to login yet.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.meeting_room, color: Colors.white, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'MFU Room Reservation',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Login to continue',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: loading ? null : _tryLogin,
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text(
                        "Create new account",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// REGISTER PAGE (same as yours)
// ------------------------------------------------------
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

  Future<void> _showMsg(String msg) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _register() async {
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;
    final c = _confirmCtrl.text;
    if (u.isEmpty || p.isEmpty) return _showMsg("Please fill all fields");
    if (p != c) return _showMsg("Passwords do not match");
    setState(() => loading = true);
    final ok = await ApiService.register(u, p);
    setState(() => loading = false);
    if (ok) {
      _showMsg("Registered successfully!");
      Navigator.pop(context);
    } else {
      _showMsg("Username already exists or server error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3949AB), Color(0xFF5C6BC0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.person_add_alt_1, color: Colors.white, size: 60),
                    SizedBox(height: 10),
                    Text(
                      'Student Registration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Create your student account',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _usernameCtrl,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline),
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _confirmCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: loading ? null : _register,
                        child: loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Back to Login",
                        style: TextStyle(color: Colors.indigo),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
