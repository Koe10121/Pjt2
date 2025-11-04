import 'package:flutter/material.dart';
import 'package:pjt2/student/student_home.dart';
import 'api_service.dart';

// --------------------- AppData ---------------------
class AppData {
  static Map<String, dynamic>? currentUser;

  static String get todayDate {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  static String nowTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  static Future<bool> hasActiveBookingToday(int userId) async {
    final bookings = await ApiService.getBookings(userId);
    return bookings.any((b) =>
        b['date'] == todayDate &&
        (b['status'] == 'Pending' || b['status'] == 'Approved'));
  }
}
// --------------------- end AppData ---------------------

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MFU Room Reservation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const LoginPage(),
      routes: {
        '/register': (_) => const RegisterPage(),
      },
    );
  }
}

// ------------------------------------------------------
// LOGIN PAGE
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

    if (user['role'] != 'student') {
      _showMsg("Only student login is active for now");
      return;
    }

    AppData.currentUser = user;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => StudentHomePage(
          userId: user['id'],
          username: user['username'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Text('MFU Room Reservation',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: loading ? null : _tryLogin,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/register'),
                    child: const Text("Create new account"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------
// REGISTER PAGE (Student only)
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
      _showMsg("Username already exists");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("Student Registration",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                        hintText: "Username", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: "Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: "Confirm Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: loading ? null : _register,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Register"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back to Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
