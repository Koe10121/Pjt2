import 'package:flutter/material.dart';
import '../main.dart';
import 'lecturer_home.dart'; // for logout()

class LecturerDashboardPage extends StatelessWidget {
  final VoidCallback onRefresh;
  const LecturerDashboardPage({required this.onRefresh, super.key});

  int countFree() {
    int c = 0;
    AppData.slotStatus.forEach((_, map) {
      map.forEach((_, status) {
        if (status == 'Free') c++;
      });
    });
    return c;
  }

  int countPending() {
    int c = 0;
    AppData.slotStatus.forEach((_, map) {
      map.forEach((_, status) {
        if (status == 'Pending') c++;
      });
    });
    return c;
  }

  int countReserved() {
    int c = 0;
    AppData.slotStatus.forEach((_, map) {
      map.forEach((_, status) {
        if (status == 'Reserved') c++;
      });
    });
    return c;
  }

  int countDisabled() {
    int c = 0;
    AppData.slotStatus.forEach((_, map) {
      map.forEach((_, status) {
        if (status == 'Disabled') c++;
      });
    });
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final free = countFree();
    final pending = countPending();
    final reserved = countReserved();
    final disabled = countDisabled();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Dashboard"),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context), // ✅ works now
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, Lecturer!",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text("You can manage room booking requests here",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(thickness: 1),
            const SizedBox(height: 12),
            const Text("Today's Overview",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _OverviewCard(
                        icon: Icons.meeting_room,
                        title: "Free Slots",
                        value: "$free",
                        color: Colors.green)),
                const SizedBox(width: 12),
                Expanded(
                    child: _OverviewCard(
                        icon: Icons.hourglass_empty,
                        title: "Pending Slots",
                        value: "$pending",
                        color: Colors.amber)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _OverviewCard(
                        icon: Icons.lock,
                        title: "Reserved Slots",
                        value: "$reserved",
                        color: Colors.red)),
                const SizedBox(width: 12),
                Expanded(
                    child: _OverviewCard(
                        icon: Icons.block,
                        title: "Disabled Rooms",
                        value: "$disabled",
                        color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _OverviewCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title),
        ],
      ),
    );
  }
}
