import 'package:flutter/material.dart';
import '../main.dart';

class StaffDashboardPage extends StatelessWidget {
  final VoidCallback onLogout;
  const StaffDashboardPage({required this.onLogout, super.key});

  // Count functions (same logic as lecturer dashboard)
  int countFree() {
    int c = 0;
    final now = AppData.nowTime();

    bool isTimePassed(String slotRange) {
      final parts = slotRange.split('-').map((e) => int.parse(e)).toList();
      final endHour = parts[1];

      final curParts = now.split(":").map(int.parse).toList();
      final currentTotal = curParts[0] * 60 + curParts[1];
      final endTotal = endHour * 60;

      return currentTotal >= (endTotal - 30);
    }

    AppData.slotStatus.forEach((_, map) {
      map.forEach((slotRange, status) {
        if (status == 'Free' && !isTimePassed(slotRange)) c++;
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
        // Treat backend "Approved" as reserved as well.
        if (status == 'Reserved' || status == 'Approved') c++;
      });
    });
    return c;
  }

  int countDisabled() {
    // Count disabled rooms (all slots Disabled),
    // matching the "Disabled Rooms" card label.
    int roomsDisabled = 0;
    AppData.slotStatus.forEach((_, map) {
      final allDisabled = map.values.every((status) => status == 'Disabled');
      if (allDisabled) roomsDisabled++;
    });
    return roomsDisabled;
  }

  @override
  Widget build(BuildContext context) {
    final free = countFree();
    final pending = countPending();
    final reserved = countReserved();
    final disabled = countDisabled();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff - Dashboard'),
        backgroundColor: Colors.grey[200],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: onLogout)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.indigo[300],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome, Staff!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text("MFU Room Management System", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),
          const Text("Today's Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // First row (Free / Pending)
          Row(children: [
            Expanded(
              child: _OverviewCard(
                title: "Free Slots",
                value: "$free",
                color: Colors.green,
                icon: Icons.door_front_door,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewCard(
                title: "Pending Slots",
                value: "$pending",
                color: Colors.amber,
                icon: Icons.hourglass_top,
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Second row (Reserved / Disabled)
          Row(children: [
            Expanded(
              child: _OverviewCard(
                title: "Reserved Slots",
                value: "$reserved",
                color: Colors.red,
                icon: Icons.lock,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _OverviewCard(
                title: "Disabled Rooms",
                value: "$disabled",
                color: Colors.grey,
                icon: Icons.block,
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// Reusable small card widget
class _OverviewCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _OverviewCard(
      {required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title),
      ]),
    );
  }
}
