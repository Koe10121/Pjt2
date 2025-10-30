import 'package:flutter/material.dart';
import 'package:pjt2/student/student_room_dialog.dart';
import 'student_rules.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage();

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    BrowseRoomPage(),
    StudentCheckStatusPage(),
    StudentHistoryPage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.meeting_room),
            label: "Browse Room",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Check Status",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}

// -------------------- Browse Room Page --------------------

class BrowseRoomPage extends StatefulWidget {
  const BrowseRoomPage();

  @override
  State<BrowseRoomPage> createState() => _BrowseRoomPageState();
}

class _BrowseRoomPageState extends State<BrowseRoomPage> {
  String todayDate = "2025-10-23";
  String currentTime = "9:15";

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student - Browse Room"),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.rule),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const ReservationRulesDialog(),
              );
            },
          ),
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
                    "Welcome, Student!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "MFU room reservation system",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 4),
                    Text(todayDate),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 4),
                    Text(currentTime),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            RoomCard(
              roomName: "Room X101",
              building: "Building 6",
              isDisabled: true,
              currentTime: currentTime,
              isTimePassed: isTimePassed,
            ),
            const SizedBox(height: 16),
            RoomCard(
              roomName: "Room A101",
              building: "Building 1",
              isDisabled: false,
              currentTime: currentTime,
              isTimePassed: isTimePassed,
            ),
            const SizedBox(height: 16),
            RoomCard(
              roomName: "Room B103",
              building: "Building 2",
              isDisabled: false,
              currentTime: currentTime,
              isTimePassed: isTimePassed,
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- Room Card --------------------

class RoomCard extends StatelessWidget {
  final String roomName;
  final String building;
  final bool isDisabled;
  final String currentTime;
  final bool Function(String, String) isTimePassed;

  const RoomCard({
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
                  const Text("Room "),
                  Text(roomName,
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
              buildSlot(context, "8-10", isDisabled ? "Disabled" : "Free",
                  Colors.green, "8:00"),
              buildSlot(context, "10-12", isDisabled ? "Disabled" : "Pending",
                  Colors.amber, "10:00"),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildSlot(context, "13-15", isDisabled ? "Disabled" : "Free",
                  Colors.green, "13:00"),
              buildSlot(context, "15-17", isDisabled ? "Disabled" : "Reserved",
                  Colors.blue, "15:00"),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSlot(BuildContext context, String time, String status, Color baseColor,
      String slotStartTime) {
    Color color = baseColor;

    if (status == "Free" && isTimePassed(slotStartTime, currentTime)) {
      color = Colors.grey;
    } else if (status == "Disabled") {
      color = Colors.grey;
    }

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () {
        if (status == "Disabled" || status == "Reserved" || status == "Pending") {
          showDialog(
            context: context,
            builder: (context) => const RoomUnavailableDialog(),
          );
        } else if (status == "Free") {
          if (isTimePassed(slotStartTime, currentTime)) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Cannot Reserve"),
                content: const Text(
                    "This time has already passed. You cannot reserve it."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  )
                ],
              ),
            );
          } else {
            showDialog(
              context: context,
              builder: (context) =>
                  ConfirmBookingDialog(roomName: roomName, timeSlot: time),
            );
          }
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 4),
          Text(time,
              style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
                color: Colors.indigo[800], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// -------------------- Student Check Status --------------------

class StudentCheckStatusPage extends StatelessWidget {
  const StudentCheckStatusPage();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student - Check Status'),
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
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 1.2),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.meeting_room),
                      SizedBox(width: 6),
                      Text('Room A101',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.apartment, size: 20),
                      SizedBox(width: 6),
                      Text('Building 1'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 18),
                  SizedBox(width: 6),
                  Text('Time Slot : 13-15'),
                ],
              ),
              SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, size: 18),
                  SizedBox(width: 6),
                  Text('Requested at : 09:15'),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Status : '),
                  SizedBox(width: 6),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Text('Pending',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------- Student History --------------------

class StudentHistoryPage extends StatelessWidget {
  const StudentHistoryPage();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student - History'),
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
          children: const [
            HistoryCard(
              roomName: 'Room B202',
              building: 'Building 2',
              status: 'Approved',
              color: Colors.green,
              person: 'Prof. A',
              time: '10:00',
            ),
            SizedBox(height: 16),
            HistoryCard(
              roomName: 'Room E110',
              building: 'Building 5',
              status: 'Rejected',
              color: Colors.red,
              person: 'Prof. B',
              time: '09:45',
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final String roomName;
  final String building;
  final String status;
  final Color color;
  final String person;
  final String time;

  const HistoryCard({
    required this.roomName,
    required this.building,
    required this.status,
    required this.color,
    required this.person,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400, width: 1.2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      padding: const EdgeInsets.all(16),
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
                  Text(roomName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(Icons.access_time, size: 18),
              SizedBox(width: 6),
              Text('Time Slot : 09-11'),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(Icons.schedule, size: 18),
              SizedBox(width: 6),
              Text('Requested at : 08:00'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Status : '),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person, size: 18),
              const SizedBox(width: 6),
              Text('$status by: $person'),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 18),
              const SizedBox(width: 6),
              Text('$status at: $time'),
            ],
          ),
        ],
      ),
    );
  }
}
