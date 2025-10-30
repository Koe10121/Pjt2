
import 'package:flutter/material.dart';
import '../main.dart';
import 'lecturer_home.dart';

class LecturerHistoryPage extends StatefulWidget {
  final VoidCallback onRefresh;
  const LecturerHistoryPage({required this.onRefresh, super.key});

  @override
  State<LecturerHistoryPage> createState() => _LecturerHistoryPageState();
}

class _LecturerHistoryPageState extends State<LecturerHistoryPage> {
  @override
  Widget build(BuildContext context) {
    final list = AppData.lecturerHistory;
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
        child: Column(
          children: [
            if (list.isEmpty)
              const Text('No history yet', style: TextStyle(color: Colors.black54)),
            for (var h in list)
              _LecturerHistoryCard(
                roomName: h['room'] ?? '',
                building: h['building'] ?? '',
                status: h['status'] ?? '',
                color: h['status'] == 'Approved' ? Colors.green : Colors.red,
                requestedBy: h['requestedBy'] ?? '',
                actionTime: h['actionTime'] ?? '',
                date: h['date'] ?? '',
                timeslot: h['timeslot'] ?? '-',
              ),
          ],
        ),
      ),
    );
  }
}

class _LecturerHistoryCard extends StatelessWidget {
  final String roomName, building, status, requestedBy, actionTime, date, timeslot;
  final Color color;

  const _LecturerHistoryCard({
    required this.roomName,
    required this.building,
    required this.status,
    required this.color,
    required this.requestedBy,
    required this.actionTime,
    required this.date,
    required this.timeslot,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏠 Room & Building
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.meeting_room),
                const SizedBox(width: 6),
                Text(roomName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              Row(children: [
                const Icon(Icons.apartment, size: 20),
                const SizedBox(width: 6),
                Text(building),
              ]),
            ],
          ),
          const Divider(),

          // ⏰ Time Slot
          Row(children: [
            const Icon(Icons.timelapse, size: 18),
            const SizedBox(width: 6),
            Text('Time Slot : $timeslot'),
          ]),
          const SizedBox(height: 6),

          // 📅 Date
          Row(children: [
            const Icon(Icons.calendar_today, size: 18),
            const SizedBox(width: 6),
            Text('Date : $date'),
          ]),
          const SizedBox(height: 6),

          // 🕒 Action Time
          Row(children: [
            const Icon(Icons.schedule, size: 18),
            const SizedBox(width: 6),
            Text('Action Time : $actionTime'),
          ]),
          const SizedBox(height: 8),

          // ✅ Colored status tag only (removed Status: row)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 👤 Requested by
          Text('Requested by : $requestedBy'),
        ],
      ),
    );
  }
}
