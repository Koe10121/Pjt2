import 'package:flutter/material.dart';
import '../main.dart';

class StaffBrowseRoomPage extends StatelessWidget {
  final VoidCallback onLogout;
  const StaffBrowseRoomPage({required this.onLogout, super.key});

  bool isTimePassed(String start, String now) {
    List<int> s = start.split(":").map(int.parse).toList();
    List<int> n = now.split(":").map(int.parse).toList();
    if (s[0] < n[0]) return true;
    if (s[0] == n[0] && s[1] <= n[1]) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String now = AppData.nowTime();
    final rooms = AppData.slotStatus.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Staff - Browse Rooms"),
        backgroundColor: Colors.grey[300],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: onLogout)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 4),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "Search rooms",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            for (var room in rooms)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RoomCard(room: room, building: AppData.roomBuildings[room] ?? '-', now: now),
              ),
          ],
        ),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String room;
  final String building;
  final String now;
  const RoomCard({super.key, required this.room, required this.building, required this.now});

  Color colorFor(String status, String startTime) {
    if (status == 'Reserved') return Colors.red;
    if (status == 'Pending') return Colors.amber;
    if (status == 'Disabled') return Colors.grey;
    // Free
    List<int> s = startTime.split(":").map(int.parse).toList();
    List<int> n = now.split(":").map(int.parse).toList();
    if (s[0] < n[0] || (s[0] == n[0] && s[1] <= n[1])) return Colors.grey;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[room]!;
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
            Text(room, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          Row(children: [
            const Icon(Icons.location_city, size: 18),
            const SizedBox(width: 4),
            Text(building),
          ]),
        ]),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Slot(time: "8-10", status: map['8-10']!, color: colorFor(map['8-10']!, "8:00")),
          _Slot(time: "10-12", status: map['10-12']!, color: colorFor(map['10-12']!, "10:00")),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _Slot(time: "13-15", status: map['13-15']!, color: colorFor(map['13-15']!, "13:00")),
          _Slot(time: "15-17", status: map['15-17']!, color: colorFor(map['15-17']!, "15:00")),
        ]),
      ]),
    );
  }
}

class _Slot extends StatelessWidget {
  final String time, status;
  final Color color;
  const _Slot({required this.time, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(backgroundColor: color.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.access_time, size: 16, color: color),
        const SizedBox(width: 4),
        Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 6),
        Text(status, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
