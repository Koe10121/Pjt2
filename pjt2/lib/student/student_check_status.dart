// lib/student/student_check_status.dart
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main.dart';

class StudentCheckStatusPage extends StatefulWidget {
  final int userId;
  final String username;
  const StudentCheckStatusPage({super.key, required this.userId, required this.username});

  @override
  State<StudentCheckStatusPage> createState() => _StudentCheckStatusPageState();
}

class _StudentCheckStatusPageState extends State<StudentCheckStatusPage> {
  Map<String, dynamic>? currentBooking;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadBooking();
  }

  Future<void> loadBooking() async {
    setState(() => loading = true);
    final bookings = await ApiService.getBookings(widget.userId);
    final today = AppData.todayDate;
    final latest = bookings.firstWhere((b) =>
        (b['date'] ?? '') == today &&
        ((b['status'] ?? '') == 'Pending' || (b['status'] ?? '') == 'Approved'),
        orElse: () => null);
    setState(() {
      currentBooking = latest != null ? Map<String, dynamic>.from(latest) : null;
      loading = false;
    });
  }

  void logout(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          Navigator.pop(ctx);
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }, child: const Text('Logout'))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final booking = currentBooking;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student - Check Status'),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[300],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: booking == null ? const Center(child: Text('No bookings for today.', style: TextStyle(color: Colors.black54))) :
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400, width: 1.2), borderRadius: BorderRadius.circular(12), color: Colors.grey[100]),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [const Icon(Icons.meeting_room), const SizedBox(width: 6), Text(booking['room'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              Row(children: [const Icon(Icons.apartment, size: 20), const SizedBox(width: 6), Text(booking['building'] ?? '')]),
            ]),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.access_time, size: 18), const SizedBox(width: 6), Text('Time Slot : ${booking['timeslot'] ?? ''}')]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.calendar_today, size: 18), const SizedBox(width: 6), Text('Booking Date : ${booking['date'] ?? ''}')]),
            const SizedBox(height: 6),
            Row(children: [const Icon(Icons.schedule, size: 18), const SizedBox(width: 6), Text('Booking Time : ${booking['time'] ?? ''}')]),
            const SizedBox(height: 10),
            Row(children: [
              const Text('Status : '),
              const SizedBox(width: 6),
              DecoratedBox(
                decoration: BoxDecoration(color: (booking['status'] == 'Approved') ? Colors.green : Colors.amber, borderRadius: const BorderRadius.all(Radius.circular(6))),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), child: Text(booking['status'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)))),
            ]),
          ]),
        ),
      ),
    );
  }
}
