




import 'package:flutter/material.dart';
import '../main.dart';

class StaffBrowseRoomPage extends StatefulWidget {
  final VoidCallback onLogout;
  const StaffBrowseRoomPage({required this.onLogout, super.key});

  @override
  State<StaffBrowseRoomPage> createState() => _StaffBrowseRoomPageState();
}

class _StaffBrowseRoomPageState extends State<StaffBrowseRoomPage> {
  String now = AppData.nowTime();
  String todayDate = AppData.todayDate;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    // 🔄 Auto-refresh every 30 seconds
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(() => now = AppData.nowTime());
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
        title: const Text("Staff - Browse Rooms"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout)
        ],
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
                    Text(now,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (filteredRooms.isEmpty)
              const Center(
                  child: Text("No rooms found",
                      style: TextStyle(color: Colors.black54))),

            for (var room in filteredRooms)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: RoomCard(
                  room: room,
                  building: AppData.roomBuildings[room] ?? '-',
                  now: now,
                  isTimePassed: isTimePassed,
                ),
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
  final bool Function(String, String) isTimePassed;

  const RoomCard({
    super.key,
    required this.room,
    required this.building,
    required this.now,
    required this.isTimePassed,
  });

  Color colorFor(String status, String slotRange) {
    // Backend uses "Approved" for confirmed bookings;
    // treat it the same as "Reserved" in the UI.
    if (status == 'Reserved' || status == 'Approved') return Colors.red;
    if (status == 'Pending') return Colors.amber;
    if (status == 'Disabled') return Colors.grey;
    if (status == 'Free') {
      return isTimePassed(slotRange, now) ? Colors.grey : Colors.green;
    }
    return Colors.grey;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            _Slot(time: "8-10", status: map['8-10']!, color: colorFor(map['8-10']!, "8-10")),
            _Slot(time: "10-12", status: map['10-12']!, color: colorFor(map['10-12']!, "10-12")),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _Slot(time: "13-15", status: map['13-15']!, color: colorFor(map['13-15']!, "13-15")),
            _Slot(time: "15-17", status: map['15-17']!, color: colorFor(map['15-17']!, "15-17")),
          ]),
        ],
      ),
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
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
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
