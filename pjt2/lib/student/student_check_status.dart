import 'package:flutter/material.dart';
import '../../main.dart';

class StudentCheckStatusPage extends StatefulWidget {
  const StudentCheckStatusPage({super.key});

  @override
  State<StudentCheckStatusPage> createState() => _StudentCheckStatusPageState();
}

class _StudentCheckStatusPageState extends State<StudentCheckStatusPage> {
  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booking = AppData.currentStudentBooking;


    return Scaffold(
      appBar: AppBar(
        title: const Text('Student - Check Status'),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[300],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: booking == null
            ? Center(child: Text('No pending bookings', style: TextStyle(color: Colors.black54)))
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 1.2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [const Icon(Icons.meeting_room), const SizedBox(width: 6), Text(booking['room']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                    Row(children: [const Icon(Icons.apartment, size: 20), const SizedBox(width: 6), Text(booking['building']!)]),
                  ]),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(children: [const Icon(Icons.access_time, size: 18), const SizedBox(width: 6), Text('Time Slot : ${''}${booking['timeslot']!}')]),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.calendar_today, size: 18), const SizedBox(width: 6), Text('Booking Date : ${booking['date']!}')]),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.schedule, size: 18), const SizedBox(width: 6), Text('Booking Time : ${booking['time']!}')]),
                  const SizedBox(height: 10),
                  Row(children: [
                    const Text('Status : '),
                    const SizedBox(width: 6),
                    DecoratedBox(
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.all(Radius.circular(6))),
                      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: Text('Pending', style: const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                  ]),
                ]),
              ),
      ),
    );
  }
}
