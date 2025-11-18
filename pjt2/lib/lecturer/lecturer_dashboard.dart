import 'package:flutter/material.dart';
import '../main.dart';
import 'lecturer_home.dart';

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

int countReserved() {   // NOW SHOWS APPROVED ONLY
  int c = 0;
  AppData.slotStatus.forEach((_, map) {
    map.forEach((_, status) {
      if (status == 'Approved') c++;
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.indigo[300],
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.2),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, Lecturer 👋",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Manage student booking requests efficiently",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "Today's Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.meeting_room,
                    title: "Free Slots",
                    value: "$free",
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.hourglass_empty,
                    title: "Pending Slots",
                    value: "$pending",
                    color: Colors.amber,
                  ),
                ),
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
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.block,
                    title: "Disabled Rooms",
                    value: "$disabled",
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, color: Colors.indigo),
                label: const Text(
                  "Refresh Overview",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.indigo,
                  ),
                ),
              ),
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

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: color),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
