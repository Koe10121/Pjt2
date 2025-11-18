import 'package:flutter/material.dart';
import '../main.dart';

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

  bool isTimePassed(String slotRange, String current) {
    final parts = slotRange.split('-').map(int.parse).toList();
    final end = parts[1] * 60;

    final now = current.split(":").map(int.parse).toList();
    final cur = now[0] * 60 + now[1];

    return cur >= (end - 30);
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = AppData.slotStatus.keys.toList()..sort();
    final filtered = allRooms
        .where((r) => r.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 16),
            _searchBar(),
            const SizedBox(height: 16),
            if (filtered.isEmpty)
              const Center(child: Text("No rooms found"))
            else
              Column(
                children: [
                  for (var r in filtered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _RoomCard(
                        roomName: r,
                        building: AppData.roomBuildings[r] ?? "Unknown",
                        currentTime: currentTime,
                        isTimePassed: isTimePassed,
                      ),
                    )
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _header() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.indigo[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Browse All Rooms",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
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
          hintText: "Search rooms by name...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

class _RoomCard extends StatelessWidget {
  final String roomName, building, currentTime;
  final bool Function(String, String) isTimePassed;

  const _RoomCard({
    required this.roomName,
    required this.building,
    required this.currentTime,
    required this.isTimePassed,
  });

  Color colorFor(String s, String slot) {
    if (s == 'Approved') return Colors.red;
    if (s == 'Pending') return Colors.amber;
    if (s == 'Disabled') return Colors.grey;

    if (s == 'Free') {
      return (isTimePassed(slot, currentTime)) ? Colors.grey : Colors.green;
    }

    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[roomName]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.meeting_room, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              Row(children: [
                const Icon(Icons.location_city, color: Colors.grey),
                const SizedBox(width: 6),
                Text(building, style: const TextStyle(color: Colors.black54)),
              ])
            ],
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 10),
          _slotRow("8-10", map),
          const SizedBox(height: 8),
          _slotRow("10-12", map),
          const SizedBox(height: 8),
          _slotRow("13-15", map),
          const SizedBox(height: 8),
          _slotRow("15-17", map),
        ],
      ),
    );
  }

  Widget _slotRow(String slot, Map<String, String> map) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _SlotBadge(
            label: slot,
            status: map[slot] ?? 'Free',
            color: colorFor(map[slot] ?? 'Free', slot),
          ),
        ],
      );
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
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(status, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
