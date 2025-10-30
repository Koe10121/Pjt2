
import 'package:flutter/material.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage();

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  int selectedIndex = 0;

  List<Map<String, dynamic>> rooms = [
    {'id': 1, 'name': 'Room A101', 'building': 'Building A', 'disabled': false},
    {'id': 2, 'name': 'Room B204', 'building': 'Building B', 'disabled': false},
    {'id': 3, 'name': 'Room C310', 'building': 'Building C', 'disabled': true},
    {'id': 4, 'name': 'Room D115', 'building': 'Building D', 'disabled': false},
  ];

  List<Map<String, dynamic>> history = [
    {
      'room': 'Room A101',
      'building': 'Building 1',
      'timeslot': '13-15',
      'date': '2025-10-23',
      'requestedAt': '09:15',
      'approvedAt': '11:30',
      'status': 'Approved',
      'approvedBy': 'Prof. A',
      'requestedBy': 'John Doe (ID-123)',
    },
    {
      'room': 'Room B101',
      'building': 'Building 2',
      'timeslot': '13-15',
      'date': '2025-10-23',
      'requestedAt': '09:15',
      'rejectedAt': '11:30',
      'status': 'Rejected',
      'approvedBy': 'Prof. B',
      'requestedBy': 'Jane Smith (ID-456)',
    },
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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

  void _addRoom(String name, String building) {
    if (name.isEmpty || building.isEmpty) {
      _showMessage('Please fill valid room details');
      return;
    }
    final newId = rooms.isEmpty ? 1 : (rooms.last['id'] as int) + 1;
    setState(() {
      rooms.add({'id': newId, 'name': name, 'building': building, 'disabled': false});
    });
    _showMessage('Room added');
  }

  void _editRoom(int id, String name, String building) {
    if (name.isEmpty || building.isEmpty) {
      _showMessage('Please fill valid room details');
      return;
    }
    setState(() {
      for (var r in rooms) {
        if (r['id'] == id) {
          r['name'] = name;
          r['building'] = building;
          break;
        }
      }
    });
    _showMessage('Room updated');
  }

  void _toggleRoom(int id, bool disabledValue) {
    setState(() {
      for (var r in rooms) {
        if (r['id'] == id) {
          r['disabled'] = disabledValue;
          break;
        }
      }
    });
    _showMessage(disabledValue ? 'Room disabled' : 'Room enabled');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(rooms: rooms, onLogout: _logout),
      BrowseRoomPage(onLogout: _logout),
      RoomManagementPage(
        rooms: rooms,
        onAdd: () => _showAddRoomDialog(),
        onEdit: (r) => _showEditRoomDialog(r),
        onToggle: _toggleRoom,
        onLogout: _logout,
      ),
      HistoryPage(history: history, onLogout: _logout),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.white),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Browse'),
            BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: 'Manage'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          ],
        ),
      ),
    );
  }

  // ---------- Dialogs ----------
  void _showAddRoomDialog() {
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController buildingCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a new Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'Room number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: buildingCtrl,
              decoration: InputDecoration(
                hintText: 'Building',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _addRoom(nameCtrl.text.trim(), buildingCtrl.text.trim());
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditRoomDialog(Map<String, dynamic> room) {
    final TextEditingController nameCtrl = TextEditingController(text: room['name']);
    final TextEditingController buildingCtrl = TextEditingController(text: room['building']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${room['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: 'Room number',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: buildingCtrl,
              decoration: InputDecoration(
                hintText: 'Building',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _editRoom(room['id'] as int, nameCtrl.text.trim(), buildingCtrl.text.trim());
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Dashboard ----------------

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final VoidCallback onLogout;
  const DashboardPage({required this.rooms, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    int disabled = rooms.where((r) => r['disabled'] == true).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff - Dashboard'),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.indigo[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, Staff!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text('MFU room reservation management', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),
          const Text("Today's Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: const [
              Expanded(
                  child: _OverviewCard(
                      title: 'Free Slots', value: '45', icon: Icons.door_front_door, color: Colors.green)),
              SizedBox(width: 12),
              Expanded(
                  child: _OverviewCard(
                      title: 'Pending Slots', value: '8', icon: Icons.hourglass_top, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                  child: _OverviewCard(
                      title: 'Reserved Slots', value: '15', icon: Icons.lock, color: Colors.blue)),
              const SizedBox(width: 12),
              Expanded(
                  child: _OverviewCard(
                      title: 'Disabled Rooms',
                      value: '',
                      icon: Icons.block,
                      color: Colors.red)),
            ],
          ),
        ]),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _OverviewCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(title),
        ],
      ),
    );
  }
}

// ---------------- Browse Rooms ----------------

class BrowseRoomPage extends StatelessWidget {
  final VoidCallback onLogout;
  const BrowseRoomPage({required this.onLogout});

  bool isTimePassed(String slot, String now) {
    List<int> s = slot.split(':').map(int.parse).toList();
    List<int> n = now.split(':').map(int.parse).toList();
    if (s[0] < n[0]) return true;
    if (s[0] == n[0] && s[1] <= n[1]) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String currentTime = "9:15";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff - Browse Rooms"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search rooms",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 16),
          RoomCard(roomName: "Room A101", building: "Building 1", isDisabled: false, now: currentTime, check: isTimePassed),
          const SizedBox(height: 16),
          RoomCard(roomName: "Room B102", building: "Building 2", isDisabled: true, now: currentTime, check: isTimePassed),
          const SizedBox(height: 16),
          RoomCard(roomName: "Room C201", building: "Building 3", isDisabled: false, now: currentTime, check: isTimePassed),
        ]),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String roomName, building, now;
  final bool isDisabled;
  final bool Function(String, String) check;
  const RoomCard({required this.roomName, required this.building, required this.isDisabled, required this.now, required this.check});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.meeting_room),
            const SizedBox(width: 6),
            Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          Row(children: [
            const Icon(Icons.apartment, size: 18),
            const SizedBox(width: 4),
            Text(building),
          ]),
        ]),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Slot(label: "8-10", status: isDisabled ? "Disabled" : "Free", color: isDisabled ? Colors.grey : (check("8:00", now) ? Colors.grey : Colors.green)),
          _Slot(label: "10-12", status: isDisabled ? "Disabled" : "Pending", color: isDisabled ? Colors.grey : Colors.amber),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Slot(label: "13-15", status: isDisabled ? "Disabled" : "Free", color: isDisabled ? Colors.grey : (check("13:00", now) ? Colors.grey : Colors.green)),
          _Slot(label: "15-17", status: isDisabled ? "Disabled" : "Reserved", color: isDisabled ? Colors.grey : Colors.blue),
        ]),
      ]),
    );
  }
}

class _Slot extends StatelessWidget {
  final String label, status;
  final Color color;
  const _Slot({required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(backgroundColor: color.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.access_time, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 6),
        Text(status, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ---------------- Manage Rooms ----------------
class RoomManagementPage extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final VoidCallback onAdd;
  final Function(Map<String, dynamic>) onEdit;
  final Function(int, bool) onToggle;
  final VoidCallback onLogout;

  const RoomManagementPage({required this.rooms, required this.onAdd, required this.onEdit, required this.onToggle, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Portal • staff'), backgroundColor: Colors.white, elevation: 1, actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: "Search rooms (e.g., B204, C310)",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("+ Add New Room", style: TextStyle(color: Colors.white, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: rooms.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final r = rooms[i];
                final bool isDisabled = r['disabled'] == true;
                final bool isEnabled = !isDisabled;
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    CircleAvatar(
                      backgroundColor: isDisabled ? Colors.orange.shade300 : Colors.green.shade300,
                      child: Icon(isDisabled ? Icons.build : Icons.meeting_room, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(r['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(r['building'], style: const TextStyle(color: Colors.black54)),
                      ]),
                    ),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => onEdit(r)),
                    Switch(
                      value: isEnabled,
                      activeColor: Colors.indigo,
                      onChanged: (val) => onToggle(r['id'] as int, !val),
                    ),
                  ]),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------------- History ----------------
class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final VoidCallback onLogout;
  const HistoryPage({required this.history, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff - History'), backgroundColor: Colors.grey[200], actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: onLogout),
      ]),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) {
          final h = history[i];
          final status = h['status'];
          final color = status == 'Approved' ? Colors.green : Colors.red;

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.meeting_room),
                  const SizedBox(width: 8),
                  Text(h['room'],
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(h['building']),
                  ),
                ]),
                const Divider(),
                Row(children: [const Text('Time Slot : '), Text(h['timeslot'])]),
                Row(children: [const Text('Booking Date : '), Text(h['date'])]),
                Row(children: [const Text('Booking Time : '), Text(h['requestedAt'])]),
                if (status == 'Approved') ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Text('Approved at : '),
                    Text(h['approvedAt'] ?? '-'),
                  ]),
                ],
                if (status == 'Rejected') ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Text('Rejected at : '),
                    Text(h['rejectedAt'] ?? '-'),
                  ]),
                ],
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  const Text('Approved by: '),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.yellow.shade200,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(h['approvedBy'] ?? '-'),
                  ),
                  const SizedBox(width: 12),
                  const Text('Requested by: '),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.blue.shade200,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(h['requestedBy'] ?? '-'),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

