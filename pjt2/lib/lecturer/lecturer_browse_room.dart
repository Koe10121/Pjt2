import 'package:flutter/material.dart';
import '../main.dart';
import 'lecturer_home.dart';

class LecturerBrowseRoomPage extends StatefulWidget {
  const LecturerBrowseRoomPage({super.key});

  @override
  State<LecturerBrowseRoomPage> createState() => _LecturerBrowseRoomPageState();
}

class _LecturerBrowseRoomPageState extends State<LecturerBrowseRoomPage> {
  String currentTime = AppData.nowTime();
  String todayDate = AppData.todayDate;
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
    int endMinutes = 0;
    final curParts = currentTime.split(":").map(int.parse).toList();
    int curH = curParts[0];
    int curM = curParts[1];
    int currentTotal = curH * 60 + curM;
    int endTotal = endHour * 60 + endMinutes;
    return currentTotal >= (endTotal - 30);
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = AppData.slotStatus.keys.toList()..sort();
    final filteredRooms = allRooms
        .where((r) => r.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🗓️ Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Browse All Rooms",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            todayDate,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentTime,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Search rooms by name...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.indigo,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (filteredRooms.isEmpty)
              const Center(
                child: Text(
                  "No rooms found",
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
              )
            else
              Column(
                children: [
                  for (var r in filteredRooms)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RoomCardViewOnly(
                        roomName: r,
                        building: AppData.roomBuildings[r] ?? 'Unknown',
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

class _RoomCardViewOnly extends StatelessWidget {
  final String roomName, building, currentTime;
  final bool Function(String, String) isTimePassed;

  const _RoomCardViewOnly({
    required this.roomName,
    required this.building,
    required this.currentTime,
    required this.isTimePassed,
  });

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[roomName]!;

    Color colorFor(String status, String slotRange) {
      if (status == 'Reserved') return Colors.red;
      if (status == 'Pending') return Colors.amber;
      if (status == 'Disabled') return Colors.grey;

      if (status == 'Free') {
        return isTimePassed(slotRange, currentTime)
            ? Colors.grey
            : Colors.green;
      }
      return Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.meeting_room, color: Colors.indigo),
                  const SizedBox(width: 6),
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.location_city, size: 18, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(building, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SlotBadge(
                label: "8-10",
                status: map['8-10']!,
                color: colorFor(map['8-10']!, "8-10"),
              ),
              _SlotBadge(
                label: "10-12",
                status: map['10-12']!,
                color: colorFor(map['10-12']!, "10-12"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SlotBadge(
                label: "13-15",
                status: map['13-15']!,
                color: colorFor(map['13-15']!, "13-15"),
              ),
              _SlotBadge(
                label: "15-17",
                status: map['15-17']!,
                color: colorFor(map['15-17']!, "15-17"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label, status;
  final Color color;

  const _SlotBadge({
    required this.label,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18), // background tint
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 16, color: color), // keep colored icon
          const SizedBox(width: 6),

          // SLOT TIME (always black text)
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 6),

          // STATUS TEXT (always black text)
          Text(
            status,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
