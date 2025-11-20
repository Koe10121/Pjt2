import 'package:flutter/material.dart';
import '../main.dart';
import '../api_service.dart';

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

    // Ensure it is readable list
    records = AppData.staffHistory.map((e) => Map<String, dynamic>.from(e)).toList();

    // Sort newest first
    records.sort((a, b) => (b["date"] ?? "").compareTo(a["date"] ?? ""));

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Staff - Lecturer History",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[200],
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
                    final status = h["status"] ?? "-";

                    final color = status == "Approved"
                        ? Colors.green
                        : status == "Rejected"
                            ? Colors.red
                            : Colors.grey;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Room + Building
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                h["room"] ?? '-',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo),
                              ),
                              Text(
                                h["building"] ?? '-',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 14),
                              )
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text("Timeslot: ${h["timeslot"]}", style: const TextStyle(fontSize: 14)),
                          Text("Date: ${h["date"]}", style: const TextStyle(fontSize: 14)),

                          const SizedBox(height: 8),

                          // Status badge
                          Row(
                            children: [
                              const Text("Status: ",
                                  style: TextStyle(fontWeight: FontWeight.w600)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text("Requested by: ${h["requestedBy"]}",
                              style: const TextStyle(fontSize: 14)),
                          Text("Action by Lecturer: ${h["lecturer"]}",
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
