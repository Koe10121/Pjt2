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
    final curParts = currentTime.split(":").map(int.parse).toList();
    final currentTotal = curParts[0] * 60 + curParts[1];
    final endTotal = endHour * 60;
    return currentTotal >= (endTotal - 30);
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = AppData.slotStatus.keys.toList()..sort();
    final filteredRooms = allRooms
        .where((r) => r.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text("Browse Rooms"),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await AppData.loadRoomData();
              setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: widget.onLogout,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await AppData.loadRoomData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome card (matches student/lecturer style)
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome, Staff!", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("MFU Room Reservation — Browse rooms (read-only view)", style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Date / Time info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.calendar_today, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(todayDate, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                    Row(children: [
                      const Icon(Icons.access_time, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Text(now, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Search
              TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Search rooms by name...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),

              // Room list
              if (filteredRooms.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
                  ),
                  child: const Center(child: Text("No rooms found", style: TextStyle(color: Colors.black54))),
                )
              else
                Column(
                  children: [
                    for (var room in filteredRooms)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _RoomCard(
                          roomName: room,
                          building: AppData.roomBuildings[room] ?? '-',
                          currentTime: now,
                          isTimePassed: isTimePassed,
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

class _RoomCard extends StatelessWidget {
  final String roomName;
  final String building;
  final String currentTime;
  final bool Function(String, String) isTimePassed;

  const _RoomCard({
    required this.roomName,
    required this.building,
    required this.currentTime,
    required this.isTimePassed,
  });

  Color colorFor(String s, String slot) {
    if (s == 'Approved' || s == 'Reserved') return Colors.red;
    if (s == 'Pending') return Colors.amber;
    if (s == 'Disabled') return Colors.grey;
    if (s == 'Free' && isTimePassed(slot, currentTime)) return Colors.grey;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[roomName] ?? {
      '8-10': 'Free',
      '10-12': 'Free',
      '13-15': 'Free',
      '15-17': 'Free',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              const Icon(Icons.meeting_room, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            Row(children: [
              const Icon(Icons.location_city, color: Colors.indigo),
              const SizedBox(width: 8),
              Text(building, style: const TextStyle(color: Colors.black54)),
            ]),
          ]),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _SlotBadge(label: "8-10", status: map['8-10'] ?? 'Free', color: colorFor(map['8-10'] ?? 'Free', "8-10")),
            _SlotBadge(label: "10-12", status: map['10-12'] ?? 'Free', color: colorFor(map['10-12'] ?? 'Free', "10-12")),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _SlotBadge(label: "13-15", status: map['13-15'] ?? 'Free', color: colorFor(map['13-15'] ?? 'Free', "13-15")),
            _SlotBadge(label: "15-17", status: map['15-17'] ?? 'Free', color: colorFor(map['15-17'] ?? 'Free', "15-17")),
          ]),
        ],
      ),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label, status;
  final Color color;
  const _SlotBadge({required this.label, required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(Icons.access_time, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 8),
        Text(status == 'Approved' ? 'Reserved' : status, style: const TextStyle(color: Colors.indigo)),
      ]),
    );
  }
}
