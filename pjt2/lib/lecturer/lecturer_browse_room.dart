import 'package:flutter/material.dart';
import '../main.dart';

class LecturerBrowseRoomPage extends StatefulWidget {
  const LecturerBrowseRoomPage({super.key});

  @override
  State<LecturerBrowseRoomPage> createState() => _LecturerBrowseRoomPageState();
}

class _LecturerBrowseRoomPageState extends State<LecturerBrowseRoomPage> {
  String todayDate = AppData.todayDate;
  String currentTime = AppData.nowTime();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(() => currentTime = AppData.nowTime());
      return true;
    });
  }

  bool isTimePassed(String slotRange, String currentTime) {
    final parts = slotRange.split('-').map(int.parse).toList();
    final endHour = parts[1];
    final cur = currentTime.split(":").map(int.parse).toList();
    return (cur[0] * 60 + cur[1]) >= (endHour * 60 - 30);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = AppData.slotStatus.keys.toList()..sort();
    final filtered = rooms
        .where((e) => e.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.indigo[50],

      

      // ---------------- MAIN CONTENT ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // WELCOME (same as staff)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Welcome, Lecturer!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  SizedBox(height: 6),
                  Text("MFU Room Reservation — Browse rooms",
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // DATE & TIME (same as staff)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.calendar_today, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(todayDate,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  Row(children: [
                    const Icon(Icons.access_time, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(currentTime,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SEARCH BAR
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search rooms…",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ROOM LIST
            if (filtered.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text("No rooms found")),
              )
            else
              Column(
                children: [
                  for (var room in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: LecturerRoomCard(
                        roomName: room,
                        building: AppData.roomBuildings[room] ?? "-",
                        slotStatus: AppData.slotStatus[room] ?? {},
                        currentTime: currentTime,
                        isTimePassed: isTimePassed,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class LecturerRoomCard extends StatelessWidget {
  final String roomName;
  final String building;
  final String currentTime;
  final Map<String, String> slotStatus;
  final bool Function(String, String) isTimePassed;

  const LecturerRoomCard({
    super.key,
    required this.roomName,
    required this.building,
    required this.currentTime,
    required this.slotStatus,
    required this.isTimePassed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.meeting_room, color: Colors.indigo),
                const SizedBox(width: 8),
                Text(roomName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              Row(children: [
                const Icon(Icons.location_city,
                    size: 18, color: Colors.indigo),
                const SizedBox(width: 4),
                Text(building, style: const TextStyle(color: Colors.black54)),
              ]),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),

          // -------- SAME 2x2 LAYOUT AS STAFF --------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LecturerSlot(label: "8-10", status: slotStatus["8-10"] ?? "Free", current: currentTime, isTimePassed: isTimePassed),
              _LecturerSlot(label: "10-12", status: slotStatus["10-12"] ?? "Free", current: currentTime, isTimePassed: isTimePassed),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LecturerSlot(label: "13-15", status: slotStatus["13-15"] ?? "Free", current: currentTime, isTimePassed: isTimePassed),
              _LecturerSlot(label: "15-17", status: slotStatus["15-17"] ?? "Free", current: currentTime, isTimePassed: isTimePassed),
            ],
          ),
        ],
      ),
    );
  }
}

class _LecturerSlot extends StatelessWidget {
  final String label;
  final String status;
  final String current;
  final bool Function(String, String) isTimePassed;

  const _LecturerSlot({
    required this.label,
    required this.status,
    required this.current,
    required this.isTimePassed,
  });

  @override
  Widget build(BuildContext context) {
    String s = status;
    if (s == "Approved") s = "Reserved";

    Color c = Colors.green;
    if (s == "Pending") c = Colors.amber;
    if (s == "Reserved") c = Colors.red;
    if (s == "Disabled") c = Colors.grey;
    if (s == "Free" && isTimePassed(label, current)) c = Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      width: (MediaQuery.of(context).size.width - 80) / 2,
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.access_time, size: 16, color: c),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, color: c)),
        const SizedBox(width: 8),
        Text(s, style: const TextStyle(color: Colors.indigo)),
      ]),
    );
  }
}
