
import 'package:flutter/material.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage();

  @override
  State<LecturerHomePage> createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  int selectedIndex = 0;
  int pendingRequests = 2; // Example: 2 requests waiting

  final List<Widget> pages = [
    const LecturerDashboardPage(),
    const LecturerBrowseRoomPage(),
    const LecturerRequestsPage(),
    const LecturerHistoryPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: "Dashboard"),
          const BottomNavigationBarItem(
              icon: Icon(Icons.meeting_room), label: "Rooms"),

          // ✅ Notification badge moved to bottom-right
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.report),
                Positioned(
                  right: -6,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      "2",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            label: "Requests",
          ),

          const BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}

void logout(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
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

// -------------------------------------------------------------
// DASHBOARD PAGE
// -------------------------------------------------------------

class LecturerDashboardPage extends StatelessWidget {
  const LecturerDashboardPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Dashboard"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          )
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, Lecturer!",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  "You can manage room booking requests here",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(thickness: 1),
          const SizedBox(height: 12),
          const Text("Today's Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: OverviewCard(
                    icon: Icons.meeting_room,
                    title: "Free Slots",
                    value: "45",
                    color: Colors.green),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OverviewCard(
                    icon: Icons.hourglass_empty,
                    title: "Pending Slots",
                    value: "8",
                    color: Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: OverviewCard(
                    icon: Icons.lock,
                    title: "Reserved Slots",
                    value: "15",
                    color: Colors.blue),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OverviewCard(
                    icon: Icons.block,
                    title: "Disabled Rooms",
                    value: "2",
                    color: Colors.red),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}

class OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const OverviewCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(value,
              style:
                  TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// BROWSE ROOM PAGE (unchanged, same UI)
// -------------------------------------------------------------

class LecturerBrowseRoomPage extends StatelessWidget {
  const LecturerBrowseRoomPage();

  bool isTimePassed(String slotStartTime, String currentTime) {
    List<int> slotParts = slotStartTime.split(":").map(int.parse).toList();
    List<int> currentParts = currentTime.split(":").map(int.parse).toList();
    if (slotParts[0] < currentParts[0]) return true;
    if (slotParts[0] == currentParts[0] && slotParts[1] <= currentParts[1]) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String currentTime = "9:15";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Browse Room"),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search rooms",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            RoomCardViewOnly(
              roomName: "Room X101",
              building: "Building 6",
              isDisabled: true,
              isTimePassed: isTimePassed,
              currentTime: currentTime,
            ),
            const SizedBox(height: 16),
            RoomCardViewOnly(
              roomName: "Room A101",
              building: "Building 1",
              isDisabled: false,
              isTimePassed: isTimePassed,
              currentTime: currentTime,
            ),
            const SizedBox(height: 16),
            RoomCardViewOnly(
              roomName: "Room B103",
              building: "Building 2",
              isDisabled: false,
              isTimePassed: isTimePassed,
              currentTime: currentTime,
            ),
          ],
        ),
      ),
    );
  }
}

class RoomCardViewOnly extends StatelessWidget {
  final String roomName;
  final String building;
  final bool isDisabled;
  final String currentTime;
  final bool Function(String, String) isTimePassed;

  const RoomCardViewOnly({
    required this.roomName,
    required this.building,
    required this.isDisabled,
    required this.currentTime,
    required this.isTimePassed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.meeting_room),
                  const SizedBox(width: 6),
                  Text("Room $roomName",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_city, size: 18),
                  const SizedBox(width: 4),
                  Text(building),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SlotBadge(
                label: "8-10",
                status: isDisabled ? "Disabled" : "Free",
                color: isDisabled
                    ? Colors.grey
                    : (isTimePassed("8:00", currentTime)
                        ? Colors.grey
                        : Colors.green),
              ),
              _SlotBadge(
                label: "10-12",
                status: isDisabled ? "Disabled" : "Pending",
                color: isDisabled ? Colors.grey : Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SlotBadge(
                label: "13-15",
                status: isDisabled ? "Disabled" : "Free",
                color: isDisabled
                    ? Colors.grey
                    : (isTimePassed("13:00", currentTime)
                        ? Colors.grey
                        : Colors.green),
              ),
              _SlotBadge(
                label: "15-17",
                status: isDisabled ? "Disabled" : "Reserved",
                color: isDisabled ? Colors.grey : Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label;
  final String status;
  final Color color;

  const _SlotBadge({
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text(status,
              style: const TextStyle(
                  color: Colors.indigo, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// REQUESTS PAGE (only added confirmation popup)
// -------------------------------------------------------------

class LecturerRequestsPage extends StatelessWidget {
  const LecturerRequestsPage();

  void confirmAction(BuildContext context, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Request'),
        content: Text('Are you sure you want to $action this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request $action successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Requests"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _RequestCard(
              roomName: "Room A101",
              building: "Building 1",
              timeslot: "13-15",
              date: "2025-10-23",
              time: "09:15",
              requestedBy: "John Doe (ID-123)",
              onApprove: () => confirmAction(context, 'Approve'),
              onReject: () => confirmAction(context, 'Reject'),
            ),
            const SizedBox(height: 16),
            _RequestCard(
              roomName: "Room B101",
              building: "Building 2",
              timeslot: "13-15",
              date: "2025-10-23",
              time: "09:15",
              requestedBy: "Jane Smith (ID-456)",
              onApprove: () => confirmAction(context, 'Approve'),
              onReject: () => confirmAction(context, 'Reject'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String roomName, building, timeslot, date, time, requestedBy;
  final VoidCallback onApprove, onReject;

  const _RequestCard({
    required this.roomName,
    required this.building,
    required this.timeslot,
    required this.date,
    required this.time,
    required this.requestedBy,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.meeting_room),
                const SizedBox(width: 6),
                Text(roomName,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.apartment, size: 20),
                const SizedBox(width: 6),
                Text(building),
              ],
            ),
          ],
        ),
        const Divider(),
        Row(children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 6),
          Text('Time Slot : $timeslot'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 6),
          Text('Booking Date : $date'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.schedule, size: 18),
          const SizedBox(width: 6),
          Text('Booking Time : $time'),
        ]),
        const SizedBox(height: 6),
        Text("Requested by : $requestedBy",
            style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: onReject,
              child:
                  const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: onApprove,
              child:
                  const Text('Approve', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ]),
    );
  }
}

// -------------------------------------------------------------
// HISTORY PAGE (unchanged)
// -------------------------------------------------------------

class LecturerHistoryPage extends StatelessWidget {
  const LecturerHistoryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - History"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: const [
          LecturerHistoryCard(
            roomName: 'Room A101',
            building: 'Building 1',
            status: 'Approved',
            color: Colors.green,
            requestedBy: 'John Doe (ID-123)',
            actionTime: '11:30',
          ),
          SizedBox(height: 16),
          LecturerHistoryCard(
            roomName: 'Room B101',
            building: 'Building 2',
            status: 'Rejected',
            color: Colors.red,
            requestedBy: 'Jane Smith (ID-456)',
            actionTime: '11:30',
          ),
        ]),
      ),
    );
  }
}

class LecturerHistoryCard extends StatelessWidget {
  final String roomName, building, status, requestedBy, actionTime;
  final Color color;

  const LecturerHistoryCard({
    required this.roomName,
    required this.building,
    required this.status,
    required this.color,
    required this.requestedBy,
    required this.actionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.meeting_room),
                const SizedBox(width: 6),
                Text(roomName,
                    style:
                        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.apartment, size: 20),
                const SizedBox(width: 6),
                Text(building),
              ],
            ),
          ],
        ),
        const Divider(),
        Row(children: [
          const Icon(Icons.access_time, size: 18),
          const SizedBox(width: 6),
          const Text('Time Slot : 13-15'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.calendar_today, size: 18),
          const SizedBox(width: 6),
          const Text('Booking Date : 2025-10-23'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.schedule, size: 18),
          const SizedBox(width: 6),
          const Text('Booking Time : 09:15'),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(status == 'Approved' ? Icons.check_circle : Icons.cancel,
              size: 18, color: color),
          const SizedBox(width: 6),
          Text('$status Time : $actionTime'),
        ]),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
          child: Text(status,
              style:
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text('Requested by : $requestedBy'),
      ]),
    );
  }
}
