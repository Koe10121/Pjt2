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

      body: list.isEmpty
          ? const Center(
              child: Text("No history yet",
                  style: TextStyle(color: Colors.black54, fontSize: 16)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var h in list)
                    _LecturerHistoryCard(
                      roomName: h['room'] ?? '',
                      building: h['building'] ?? '',
                      status: h['status'] ?? '',
                      color: h['status'] == 'Approved'
                          ? Colors.green
                          : Colors.red,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3))
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏢 Room and Building
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.meeting_room, color: Colors.indigo),
                const SizedBox(width: 6),
                Text(roomName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              Row(children: [
                const Icon(Icons.apartment, size: 20, color: Colors.grey),
                const SizedBox(width: 6),
                Text(building,
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w500)),
              ]),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(thickness: 1),
          const SizedBox(height: 8),

          // ⏰ Timeslot, Date, and Action Time
          _infoRow(Icons.access_time, "Time Slot : $timeslot"),
          const SizedBox(height: 6),
          _infoRow(Icons.calendar_today, "Date : $date"),
          const SizedBox(height: 6),
          _infoRow(Icons.schedule, "Action Time : $actionTime"),
          const SizedBox(height: 10),

          // ✅ Status Tag
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 👤 Requested by
          Row(
            children: [
              const Icon(Icons.person_outline,
                  color: Colors.indigo, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Requested by: $requestedBy",
                  style: const TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.indigo),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
