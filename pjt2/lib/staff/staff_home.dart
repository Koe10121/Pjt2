import 'package:flutter/material.dart';
import '../main.dart';
import '../api_service.dart';
import 'staff_dashboard.dart';
import 'staff_browse_room.dart';
import 'staff_manage.dart';
import 'staff_history.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int _selectedIndex = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    setState(() => _loading = true);

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
    statuses.forEach((_, map) {
      if (map is Map && map['room_name'] != null && map['slots'] != null) {
        final rname = map['room_name'];
        final roomMap = AppData.slotStatus[rname];
        if (roomMap != null) {
          final disabled = map['disabled'] == 1;
          if (disabled) {
            roomMap.updateAll((key, value) => 'Disabled');
          } else {
            final slots = Map<String, dynamic>.from(map['slots']);
            slots.forEach((slot, status) {
              roomMap[slot] = status ?? 'Free';
            });
          }
        }
      }
    });

    setState(() => _loading = false);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  // Trigger a rebuild across pages (used after manage changes)
  void _refreshAll() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pages = [
      StaffDashboardPage(onLogout: _logout),
      StaffBrowseRoomPage(onLogout: _logout),
      StaffManagePage(onLogout: _logout, onChange: _refreshAll),
      StaffHistoryPage(onLogout: _logout),
    ];

    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
