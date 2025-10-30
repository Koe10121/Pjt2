
import 'package:flutter/material.dart';
import 'package:pjt2/student/student_home.dart';
import 'package:pjt2/lecturer/lecturer_home.dart';
import 'package:pjt2/staff/staff_home.dart';

// ----------------- AppData -----------------
class AppData {
  static Map<String, String>? currentStudentBooking;

  static List<Map<String, String>> lecturerRequests = [];

  static List<Map<String, String>> lecturerHistory = [
    {
      'room': 'Room A101',
      'building': 'Building 1',
      'timeslot': '13-15',
      'date': '2025-10-23',
      'time': '09:15',
      'status': 'Approved',
      'actionBy': 'Prof. A',
      'actionTime': '11:30',
      'requestedBy': 'Student A (ID-123)',
    },
    {
      'room': 'Room B101',
      'building': 'Building 2',
      'timeslot': '15-17',
      'date': '2025-10-23',
      'time': '09:45',
      'status': 'Rejected',
      'actionBy': 'Prof. B',
      'actionTime': '11:35',
      'requestedBy': 'Student B (ID-456)',
    },
  ];

  static List<Map<String, String>> studentHistory = [];

  static Map<String, Map<String, String>> slotStatus = {
    'Room X101': {
      '8-10': 'Disabled',
      '10-12': 'Disabled',
      '13-15': 'Disabled',
      '15-17': 'Disabled',
    },
    'Room A101': {
      '8-10': 'Free',
      '10-12': 'Free',
      '13-15': 'Free',
      '15-17': 'Pending', // example pending slot
    },
    'Room B103': {
      '8-10': 'Free',
      '10-12': 'Free',
      '13-15': 'Free',
      '15-17': 'Reserved',
    },
  };

  static Map<String, String> roomBuildings = {
    'Room X101': 'Building 6',
    'Room A101': 'Building 1',
    'Room B103': 'Building 2',
  };

  static String todayDate = "2025-10-23";

  static String nowTime() => "10:00";

  static bool hasActiveBookingToday() {
    if (currentStudentBooking != null) return true;
    for (var h in studentHistory) {
      if (h['date'] == todayDate && h['status'] == 'Approved') return true;
    }
    return false;
  }

  static void makeStudentBooking(String room, String building, String timeSlot) {
    final req = {
      'room': room,
      'building': building,
      'timeslot': timeSlot,
      'date': todayDate,
      'time': nowTime(),
      'requestedBy': 'Student A (ID-001)',
    };
    currentStudentBooking = req;
    lecturerRequests.add(req);
    slotStatus[room]?[timeSlot] = 'Pending';
    roomBuildings[room] = building;
  }

  static String getSlotStatus(String room, String timeslot) {
    if (!slotStatus.containsKey(room)) return 'Free';
    return slotStatus[room]?[timeslot] ?? 'Free';
  }

  static void lecturerAction(int reqIndex, String action, String actionBy) {
    final req = lecturerRequests.removeAt(reqIndex);
    final hist = {
      ...req,
      'status': action,
      'actionBy': actionBy,
      'actionTime': nowTime(),
    };
    lecturerHistory.insert(0, hist);
    studentHistory.insert(0, hist);

    if (currentStudentBooking != null) {
      final cur = currentStudentBooking!;
      if (cur['room'] == req['room'] && cur['timeslot'] == req['timeslot']) {
        currentStudentBooking = null;
      }
    }

    final room = req['room']!;
    final timeslot = req['timeslot']!;
    if (action == 'Approved') {
      slotStatus[room]?[timeslot] = 'Reserved';
    } else {
      slotStatus[room]?[timeslot] = 'Free';
    }
  }

  static void staffAddRoom(String roomName, String building) {
    if (!roomName.toLowerCase().startsWith('room ')) roomName = 'Room $roomName';
    if (!building.toLowerCase().startsWith('building '))
      building = 'Building $building';

    if (slotStatus.containsKey(roomName)) return;
    slotStatus[roomName] = {
      '8-10': 'Free',
      '10-12': 'Free',
      '13-15': 'Free',
      '15-17': 'Free',
    };
    roomBuildings[roomName] = building;
  }

  static void staffEditRoom(String oldName, String newName, String newBuilding) {
    if (!newName.toLowerCase().startsWith('room ')) newName = 'Room $newName';
    if (!newBuilding.toLowerCase().startsWith('building '))
      newBuilding = 'Building $newBuilding';

    if (oldName == newName) {
      roomBuildings[oldName] = newBuilding;
      return;
    }

    final map = slotStatus.remove(oldName);
    if (map != null) {
      slotStatus[newName] = map;
      roomBuildings.remove(oldName);
      roomBuildings[newName] = newBuilding;
    } else {
      slotStatus[newName] = {
        '8-10': 'Free',
        '10-12': 'Free',
        '13-15': 'Free',
        '15-17': 'Free',
      };
      roomBuildings[newName] = newBuilding;
    }
  }

  static void staffToggleRoomDisabled(String roomName, bool disabled) {
    if (!slotStatus.containsKey(roomName)) return;
    final map = slotStatus[roomName]!;
    map.forEach((k, v) {
      map[k] = disabled ? 'Disabled' : 'Free';
    });
  }

  // 🟢 NEW: Initialize any existing "Pending" slots as lecturerRequests
  static void initializePendingRequests() {
    for (var entry in slotStatus.entries) {
      final room = entry.key;
      final building = roomBuildings[room] ?? 'Building ?';
      for (var slot in entry.value.entries) {
        if (slot.value == 'Pending') {
          final alreadyExists = lecturerRequests.any((r) =>
              r['room'] == room &&
              r['timeslot'] == slot.key &&
              r['date'] == todayDate);
          if (!alreadyExists) {
            lecturerRequests.add({
              'room': room,
              'building': building,
              'timeslot': slot.key,
              'date': todayDate,
              'time': nowTime(),
              'requestedBy': 'Student (Example)',
            });
          }
        }
      }
    }
  }
}
// ----------------- end AppData -----------------

void main() {
  AppData.initializePendingRequests(); // 🟢 Auto-detect & load pending requests
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
                          style: TextStyle(fontSize: 18, color: Colors.white)),
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
                      hint: 'username',
                      obscure: false,
                      controller: _usernameCtrl),
                  _buildTextField(
                      hint: 'password',
                      obscure: true,
                      controller: _passwordCtrl),
                  _buildTextField(
                      hint: 'confirm password',
                      obscure: true,
                      controller: _confirmCtrl),
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
