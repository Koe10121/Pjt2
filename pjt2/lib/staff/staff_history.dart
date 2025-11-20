import 'package:flutter/material.dart';
import '../main.dart';

class StaffHistoryPage extends StatefulWidget {
  final VoidCallback onLogout;
  const StaffHistoryPage({required this.onLogout, super.key});

  @override
  State<StaffHistoryPage> createState() => _StaffHistoryPageState();
}

class _StaffHistoryPageState extends State<StaffHistoryPage> {
  bool loading = true;
  List<Map<String, dynamic>> records = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => loading = true);
    await AppData.loadAllLecturerHistoryForStaff();
    records = AppData.staffHistory.map((e) => Map<String, dynamic>.from(e)).toList();

    // sort by date/time: newest first when possible
    records.sort((a, b) {
      final da = (a['date'] ?? '').toString();
      final db = (b['date'] ?? '').toString();
      if (db != da) return db.compareTo(da);
      // fallback to time field if present
      final ta = (a['time'] ?? '').toString();
      final tb = (b['time'] ?? '').toString();
      return tb.compareTo(ta);
    });

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text("Lecturer History"),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHistory),
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : records.isEmpty
              ? const Center(child: Text("No history found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: records.length,
                  itemBuilder: (context, i) {
                    final h = records[i];
                    final status = (h["status"] ?? "-").toString();
                    final color = status == "Approved" ? Colors.green : status == "Rejected" ? Colors.red : Colors.grey;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 4))],
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text(h["room"] ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          Text(h["building"] ?? '-', style: const TextStyle(color: Colors.black54)),
                        ]),
                        const SizedBox(height: 8),
                        Text("Timeslot: ${h["timeslot"] ?? '-'}"),
                        Text("Date: ${h["date"] ?? '-'}  ${h["time"] ?? ''}"),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Text("Status: ", style: TextStyle(fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(8)),
                            child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        Text("Requested by: ${h["requestedBy"] ?? '-'}"),
                        Text("Action by Lecturer: ${h["lecturer"] ?? '-'}"),
                      ]),
                    );
                  },
                ),
    );
  }
}
