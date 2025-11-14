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
    final isApprove = action == 'Approve';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '$action Request',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to ${action.toLowerCase()} this booking?',
          style: const TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              AppData.lecturerAction(
                idx,
                isApprove ? 'Approved' : 'Rejected',
                'Lecturer',
              );
              setState(() {});
              widget.onRefresh();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Request ${action.toLowerCase()}ed successfully!',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: isApprove ? Colors.green : Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            child: const Text(
              'Confirm',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqs = AppData.lecturerRequests;

    return Scaffold(
      body: reqs.isEmpty
          ? const Center(
              child: Text(
                "No pending requests",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                ],
              ),
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏢 Header (room + building)
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
                  const Icon(Icons.apartment, size: 20, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(building, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 1),
          const SizedBox(height: 10),

          // ⏰ Time and Date Info
          _infoRow(Icons.access_time, "Time Slot : $timeslot"),
          const SizedBox(height: 6),
          _infoRow(Icons.calendar_today, "Booking Date : $date"),
          const SizedBox(height: 6),
          _infoRow(Icons.schedule, "Booking Time : $time"),
          const SizedBox(height: 10),
          Text(
            "Requested by : $requestedBy",
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                label: const Text(
                  "Reject",
                  style: TextStyle(color: Colors.white), 
                ),
                onPressed: onReject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.white, size: 18),
                label: const Text(
                  "Approve",
                  style: TextStyle(color: Colors.white), 
                ),
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
