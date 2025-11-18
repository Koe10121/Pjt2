// lib/lecturer/lecturer_home.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../api_service.dart';
import 'lecturer_dashboard.dart';
import 'lecturer_browse_room.dart';
import 'lecturer_requests.dart';
import 'lecturer_history.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  int selectedIndex = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

 Future<void> _loadAllData() async {
  setState(() => loading = true);

  // 1️⃣ Load rooms
  final rooms = await ApiService.getRooms();
  AppData.slotStatus.clear();
  AppData.roomBuildings.clear();
  AppData.roomIds.clear();
  for (var room in rooms) {
    final name = room['name'] as String;
    final id = room['id'] as int;
    AppData.slotStatus[name] = {
      '8-10': 'Free',
      '10-12': 'Free',
      '13-15': 'Free',
      '15-17': 'Free',
    };
    AppData.roomBuildings[name] = room['building'] as String;
    AppData.roomIds[name] = id;
  }

  // 2️⃣ Load today's room statuses
  final statuses = await ApiService.getRoomStatuses(AppData.todayDate);
  statuses.forEach((roomId, map) {
    if (map is Map && map['room_name'] != null && map['slots'] != null) {
      final rname = map['room_name'];
      final m = AppData.slotStatus[rname];
      if (m != null) {
        final disabled = map['disabled'] == 1;
        if (disabled) {
          m.updateAll((key, value) => 'Disabled');
        } else {
          final slots = Map<String, dynamic>.from(map['slots']);
          slots.forEach((slot, status) {
            m[slot] = status ?? 'Free';
          });
        }
      }
    }
  });

  // 3️⃣ Load lecturer requests (today only) + history
  AppData.lecturerRequests =
      List<Map<String, dynamic>>.from(await ApiService.getLecturerRequests());
  final id = AppData.currentUser?['id'] ?? 0;
  AppData.lecturerHistory =
      List<Map<String, dynamic>>.from(await ApiService.getLecturerHistory(id));

  setState(() => loading = false);
}


  @override
  Widget build(BuildContext context) {
    final pages = [
      LecturerDashboardPage(onRefresh: _loadAllData),
      const LecturerBrowseRoomPage(),
      LecturerRequestsPage(onRefresh: _loadAllData),
      LecturerHistoryPage(onRefresh: _loadAllData),
    ];

    final titles = [
      "Dashboard",
      "Browse Rooms",
      "Requests",
      "History",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lecturer - ${titles[selectedIndex]}",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded), label: "Dashboard"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room_outlined), label: "Rooms"),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.assignment_rounded),
                if (AppData.lecturerRequests.isNotEmpty)
                  Positioned(
                    right: -6,
                    bottom: -3,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        AppData.lecturerRequests.length.toString(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: "Requests",
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded), label: "History"),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style:
                      TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
