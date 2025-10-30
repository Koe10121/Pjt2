import 'package:flutter/material.dart';
import 'package:pjt2/lecturer/lecturer_home.dart';
import 'student/student_home.dart';
import 'staff/staff_home.dart';

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
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final List<Map<String, String>> demoUsers = [
    {'username': 'student1', 'password': 'pass123', 'role': 'student'},
    {'username': 'lect1', 'password': 'lectpass', 'role': 'lecturer'},
    {'username': 'staff1', 'password': 'staffpass', 'role': 'staff'},
  ];

  Future<void> _showMessage(String text) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _tryLogin() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty) {
      await _showMessage('Enter username');
      return;
    }
    if (password.isEmpty) {
      await _showMessage('Enter password');
      return;
    }

    final user = demoUsers.firstWhere(
      (u) => u['username'] == username,
      orElse: () => {},
    );

    if (user.isEmpty) {
      await _showMessage('Username not found');
      return;
    }

    if (user['password'] != password) {
      await _showMessage('Wrong password');
      return;
    }

    final role = user['role'];

    if (role == 'student') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentHomePage()),
      );
    } else if (role == 'lecturer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LecturerHomePage()),
      );
    } else if (role == 'staff') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StaffHomePage()),
      );
    } else {
      await _showMessage('Unknown role');
    }
  }

  Widget _buildTextField({
    required String hint,
    required bool obscure,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('MFU Room Reservation',
                      style:
                          TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Sign in to continue',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  _buildTextField(
                    hint: 'Username',
                    obscure: false,
                    controller: _usernameCtrl,
                  ),
                  _buildTextField(
                    hint: 'Password',
                    obscure: true,
                    controller: _passwordCtrl,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _tryLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Sign in',
                          style:
                              TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Test accounts:\nstudent1 / pass123\nlect1 / lectpass\nstaff1 / staffpass',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text('Create a new account'),
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

// ------------------------------------------------------
// REGISTER PAGE
// ------------------------------------------------------
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  Future<void> _showMessage(String text) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _usernameExists(String name) {
    return false;
  }

  Future<void> _tryRegister() async {
    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    if (username.isEmpty) {
      await _showMessage('Enter username');
      return;
    }
    if (password.isEmpty) {
      await _showMessage('Enter password');
      return;
    }
    if (confirm.isEmpty || confirm != password) {
      await _showMessage('Passwords do not match');
      return;
    }

    await _showMessage('Registered successfully. You can now login.');
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required String hint,
    required bool obscure,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
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
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                children: [
                  const Text('MFU',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Room reservation system!',
                      style: TextStyle(color: Colors.black54)),
                  const SizedBox(height: 16),
                  _buildTextField(
                      hint: 'username', obscure: false, controller: _usernameCtrl),
                  _buildTextField(
                      hint: 'password', obscure: true, controller: _passwordCtrl),
                  _buildTextField(
                      hint: 'confirm password', obscure: true, controller: _confirmCtrl),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _tryRegister,
                      child: const Text('Register',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to Login'),
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
