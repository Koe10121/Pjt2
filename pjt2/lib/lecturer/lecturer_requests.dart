import 'package:flutter/material.dart';
import '../main.dart';
import 'lecturer_home.dart';

class LecturerRequestsPage extends StatefulWidget {
  final VoidCallback onRefresh;
  const LecturerRequestsPage({required this.onRefresh, super.key});

  @override
  State<LecturerRequestsPage> createState() => _LecturerRequestsPageState();
}

class _LecturerRequestsPageState extends State<LecturerRequestsPage> {
  void confirmAction(int idx, String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$action Request'),
        content: Text('Are you sure you want to $action this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppData.lecturerAction(idx, action == 'Approve' ? 'Approved' : 'Rejected', 'Lecturer');
              setState(() {});
              widget.onRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Request ${action}d successfully')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqs = AppData.lecturerRequests;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Requests"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (reqs.isEmpty)
            const Text('No pending requests', style: TextStyle(color: Colors.black54)),
          for (int i = 0; i < reqs.length; i++)
            _RequestCard(
              roomName: reqs[i]['room']!,
              building: reqs[i]['building']!,
              timeslot: reqs[i]['timeslot']!,
              date: reqs[i]['date']!,
              time: reqs[i]['time']!,
              requestedBy: reqs[i]['requestedBy']!,
              onApprove: () => confirmAction(i, 'Approve'),
              onReject: () => confirmAction(i, 'Reject'),
            ),
        ]),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final String roomName, building, timeslot, date, time, requestedBy;
  final VoidCallback onApprove, onReject;

  const _RequestCard({
    required this.roomName,
    required this.building,
    required this.timeslot,
    required this.date,
    required this.time,
    required this.requestedBy,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.meeting_room),
              const SizedBox(width: 6),
              Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            Row(children: [
              const Icon(Icons.apartment, size: 20),
              const SizedBox(width: 6),
              Text(building),
            ]),
          ],
        ),
        const Divider(),
        Row(children: [const Icon(Icons.access_time, size: 18), const SizedBox(width: 6), Text('Time Slot : $timeslot')]),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.calendar_today, size: 18), const SizedBox(width: 6), Text('Booking Date : $date')]),
        const SizedBox(height: 6),
        Row(children: [const Icon(Icons.schedule, size: 18), const SizedBox(width: 6), Text('Booking Time : $time')]),
        const SizedBox(height: 6),
        Text("Requested by : $requestedBy", style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: onReject,
            child: const Text('Reject', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: onApprove,
            child: const Text('Approve', style: TextStyle(color: Colors.white)),
          ),
        ]),
      ]),
    );
  }
}
