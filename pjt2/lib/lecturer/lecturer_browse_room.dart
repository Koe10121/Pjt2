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
    final parts = slotRange.split('-').map((e) => int.parse(e)).toList();
    final endHour = parts[1];
    final curParts = currentTime.split(":").map(int.parse).toList();
    final currentTotal = curParts[0] * 60 + curParts[1];
    final endTotal = endHour * 60;
    return currentTotal >= (endTotal - 30);
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = AppData.slotStatus.keys.toList()..sort();
    final filtered = allRooms
        .where((e) => e.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text(
          "Browse Rooms (Lecturer)",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _searchBar(),
            const SizedBox(height: 16),

            if (filtered.isEmpty)
              const Center(
                child: Text(
                  "No rooms found",
                  style: TextStyle(color: Colors.black54),
                ),
              ),

            for (var room in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: LecturerRoomCard(
                  roomName: room,
                  building: AppData.roomBuildings[room] ?? "-",
                  currentTime: currentTime,
                  isTimePassed: isTimePassed,
                  slotStatus: AppData.slotStatus[room] ?? {},
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Room Availability Overview",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(todayDate, style: const TextStyle(color: Colors.white70)),
                ]),
                Row(children: [
                  const Icon(Icons.access_time, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(currentTime, style: const TextStyle(color: Colors.white70)),
                ]),
              ],
            ),
          ],
        ),
      );

  Widget _searchBar() => TextField(
        onChanged: (v) => setState(() => searchQuery = v),
        decoration: InputDecoration(
          hintText: "Search rooms...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
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
    final slots = ["8-10", "10-12", "13-15", "15-17"];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (room + building)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.meeting_room, color: Colors.indigo),
                  const SizedBox(width: 6),
                  Text(
                    roomName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_city, size: 18, color: Colors.indigo),
                  const SizedBox(width: 4),
                  Text(
                    building,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 10),

          // Slots (same student design but disabled)
          Column(
            children: slots.map((slot) {
              final status = slotStatus[slot] ?? "Free";
              return _disabledSlotButton(slot, status);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _disabledSlotButton(String time, String status) {
    Color borderColor = Colors.green;
    Color bgColor = Colors.green.withOpacity(0.18);
    Color textColor = Colors.black;

    if (status == "Pending") {
      borderColor = Colors.amber;
      bgColor = Colors.amber.withOpacity(0.22);
    } else if (status == "Approved") {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.22);
    } else if (status == "Disabled") {
      borderColor = Colors.grey;
      bgColor = Colors.grey.withOpacity(0.25);
    }

    final expired = isTimePassed(time, currentTime);
    if (status == "Free" && expired) {
      borderColor = Colors.grey;
      bgColor = Colors.grey.withOpacity(0.22);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton.icon(
        onPressed: null, // ❌ DISABLED FOR LECTURER
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        icon: Icon(Icons.access_time, size: 18, color: borderColor),
        label: Text(
          "$time • ${status == 'Approved' ? 'Reserved' : status}",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
