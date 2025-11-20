// lib/student/student_check_status.dart
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main.dart';

class StudentCheckStatusPage extends StatefulWidget {
  final int userId;
  final String username;
  const StudentCheckStatusPage({
    super.key,
    required this.userId,
    required this.username,
  });

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
    try {
      final bookings = await ApiService.getBookings(widget.userId);
      final today = AppData.todayDate;

      Map<String, dynamic>? latest;
      for (var b in bookings) {
        final bDate = b['date'] ?? '';
        final bStatus = b['status'] ?? '';
        if (bDate == today && (bStatus == 'Pending' || bStatus == 'Approved' || bStatus == 'Rejected')) {
          latest = Map<String, dynamic>.from(b);
          break;
        }
      }

      setState(() {
        currentBooking = latest;
        loading = false;
      });
    } on UnauthorizedException {
      AppData.performLogout(context);
    } catch (e) {
      print('loadBooking error: $e');
      setState(() => loading = false);
    }
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppData.performLogout(context);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // (UI left unchanged — keep your existing widget tree)
    // Copy your original build method here (it was provided earlier).
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text(
          'Check Booking Status',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[600],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadBooking,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Welcome, ${widget.username}!",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          const Text("Today's Booking Status",
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    currentBooking == null
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                'No bookings for today.',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                          )
                        : Container(
                            // keep your existing booked card UI unchanged
                            padding: const EdgeInsets.all(20),
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
                                // ... copy the same content you had earlier using currentBooking ...
                                // (Use the code you already had, unchanged)
                                // Example:
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.meeting_room,
                                          color: Colors.indigo),
                                      const SizedBox(width: 6),
                                      Text(
                                        currentBooking?['room'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ]),
                                    Row(children: [
                                      const Icon(Icons.apartment,
                                          color: Colors.indigo, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        currentBooking?['building'] ?? '',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ]),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        color: Colors.indigo, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Time Slot: ${currentBooking?['timeslot'] ?? ''}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.indigo, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Date: ${currentBooking?['date'] ?? ''}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule,
                                        color: Colors.indigo, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Booked at: ${currentBooking?['time'] ?? ''}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline,
                                        color: Colors.indigo, size: 22),
                                    const SizedBox(width: 8),
                                    const Text('Status:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: (currentBooking?['status'] == 'Approved')
                                            ? Colors.green
                                            : Colors.amber,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        currentBooking?['status'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
