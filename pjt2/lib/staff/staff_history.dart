import 'package:flutter/material.dart';
import '../main.dart';

class StaffHistoryPage extends StatelessWidget {
  final VoidCallback onLogout;
  const StaffHistoryPage({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppData.lecturerHistory; // use lecturer history (approved/rejected)

    return Scaffold(
      appBar: AppBar(title: const Text("Staff - History"), backgroundColor: Colors.grey[200], actions: [IconButton(icon: const Icon(Icons.logout), onPressed: onLogout)]),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, i) {
          final h = history[i];
          final status = h['status'] ?? '';
          final color = status == 'Approved' ? Colors.green : status == 'Rejected' ? Colors.red : Colors.grey;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [const Icon(Icons.meeting_room), const SizedBox(width: 6), Text(h['room'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))]),
                Text(h['building'] ?? '-'),
              ]),
              const Divider(height: 20),
              Text("Time Slot: ${h['timeslot'] ?? '-'}"),
              Text("Date: ${h['date'] ?? '-'}"),
              const SizedBox(height: 6),
              Row(children: [
                const Text("Status: "),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                  child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [const Icon(Icons.person, size: 18), const SizedBox(width: 4), Text("Action by: ${h['actionBy'] ?? '-'}")]),
              Row(children: [const Icon(Icons.account_circle, size: 18), const SizedBox(width: 4), Text("Requested by: ${h['requestedBy'] ?? '-'}")]),
            ]),
          );
        },
      ),
    );
  }
}
