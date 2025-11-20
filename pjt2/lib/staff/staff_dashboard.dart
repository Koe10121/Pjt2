import 'package:flutter/material.dart';
import '../main.dart';

class StaffDashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  const StaffDashboardPage({required this.onLogout, super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  bool loading = false;

  int countStatus(String target) {
    int c = 0;
    AppData.slotStatus.forEach((_, map) {
      map.forEach((_, status) {
        if (status == target) c++;
      });
    });
    return c;
  }

  Future<void> _refreshOverview() async {
    setState(() => loading = true);
    try {
      await AppData.loadRoomData();
    } catch (e) {
      print("Error refreshing room data: $e");
    }
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    _refreshOverview();
  }

  @override
  Widget build(BuildContext context) {
    final free = countStatus("Free");
    final pending = countStatus("Pending");
    final approved = countStatus("Approved");
    final disabled = countStatus("Disabled");

    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loading ? null : _refreshOverview),
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome, Staff!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text("Manage rooms and view lecturer activity", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Today's Overview", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: _OverviewCard(icon: Icons.meeting_room, title: "Free Slots", value: "$free", color: Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _OverviewCard(icon: Icons.hourglass_empty, title: "Pending Slots", value: "$pending", color: Colors.amber)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _OverviewCard(icon: Icons.verified, title: "Approved Slots", value: "$approved", color: Colors.red)),
                  const SizedBox(width: 12),
                  Expanded(child: _OverviewCard(icon: Icons.block, title: "Disabled Rooms", value: "$disabled", color: Colors.grey)),
                ]),
                const SizedBox(height: 18),
                Center(
                  child: TextButton.icon(
                    onPressed: loading ? null : _refreshOverview,
                    icon: const Icon(Icons.refresh, color: Colors.indigo),
                    label: const Text("Refresh Overview", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.w600)),
                  ),
                )
              ]),
            ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _OverviewCard({required this.icon, required this.title, required this.value, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
      child: Column(children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 14)),
      ]),
    );
  }
}
