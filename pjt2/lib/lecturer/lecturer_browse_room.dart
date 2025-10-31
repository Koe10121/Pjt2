

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
      appBar: AppBar(
        title: const Text("Lecturer - Browse Room"),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[300],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🕓 Date + Time Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    const Icon(Icons.calendar_today, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(todayDate,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ]),
                  Row(children: [
                    const Icon(Icons.access_time, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(currentTime,
                        style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 🔍 Search bar
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search rooms by name...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            if (filteredRooms.isEmpty)
              const Center(
                  child: Text("No rooms found",
                      style: TextStyle(color: Colors.black54))),

            for (var r in filteredRooms)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _RoomCardViewOnly(
                  r,
                  AppData.roomBuildings[r] ?? 'Unknown',
                  currentTime,
                  isTimePassed,
                ),
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

  const _RoomCardViewOnly(this.roomName, this.building, this.currentTime, this.isTimePassed);

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[roomName]!;

    Color colorFor(String status, String slotRange) {
      if (status == 'Reserved') return Colors.red;
      if (status == 'Pending') return Colors.amber;
      if (status == 'Disabled') return Colors.grey;
      if (status == 'Free') {
        return isTimePassed(slotRange, currentTime) ? Colors.grey : Colors.green;
      }
      return Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            const Icon(Icons.meeting_room),
            const SizedBox(width: 6),
            Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold))
          ]),
          Row(children: [
            const Icon(Icons.location_city, size: 18),
            const SizedBox(width: 4),
            Text(building),
          ]),
        ]),
        const SizedBox(height: 12),
        const Divider(thickness: 1),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SlotBadge("8-10", map['8-10']!, colorFor(map['8-10']!, "8-10")),
          _SlotBadge("10-12", map['10-12']!, colorFor(map['10-12']!, "10-12")),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SlotBadge("13-15", map['13-15']!, colorFor(map['13-15']!, "13-15")),
          _SlotBadge("15-17", map['15-17']!, colorFor(map['15-17']!, "15-17")),
        ]),
      ]),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label, status;
  final Color color;

  const _SlotBadge(this.label, this.status, this.color);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
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
