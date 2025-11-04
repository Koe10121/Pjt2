import 'package:flutter/material.dart';
import 'student_browse_room.dart';
import 'student_check_status.dart';
import 'student_history.dart';

class StudentHomePage extends StatefulWidget {
  final int userId;
  final String username;

  const StudentHomePage({super.key, required this.userId, required this.username});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      BrowseRoomPage(userId: widget.userId),
      StudentCheckStatusPage(userId: widget.userId),
      StudentHistoryPage(userId: widget.userId),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room), label: "Browse Room"),
          BottomNavigationBarItem(
              icon: Icon(Icons.check_circle), label: "Check Status"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
