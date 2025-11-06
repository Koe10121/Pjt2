// import 'package:flutter/material.dart';
// import '../api_service.dart';
// import '../main.dart';

// class StudentHistoryPage extends StatefulWidget {
//   final int userId;
//   final String username;
//   const StudentHistoryPage({super.key, required this.userId, required this.username});

//   @override
//   State<StudentHistoryPage> createState() => _StudentHistoryPageState();
// }

// class _StudentHistoryPageState extends State<StudentHistoryPage> {
//   List<dynamic> history = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadHistory();
//   }

//   Future<void> loadHistory() async {
//     setState(() => loading = true);
//     final data = await ApiService.getBookings(widget.userId);
//     final filtered =
//         data.where((b) => (b['status'] == 'Approved' || b['status'] == 'Rejected')).toList();
//     setState(() {
//       history = filtered;
//       loading = false;
//     });
//   }

//   void logout(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Confirm Logout'),
//         content: const Text('Are you sure you want to logout?'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(ctx);
//               Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Logout'),
//           ),
//         ],
//       ),
//     );
//   }

//   Color getStatusColor(String status) {
//     switch (status) {
//       case 'Approved':
//         return Colors.green;
//       case 'Rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.indigo[50],
//       appBar: AppBar(
//         title: const Text(
//           'Booking History',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.indigo[600],
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () => logout(context),
//           ),
//         ],
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: loadHistory,
//               child: history.isEmpty
//                   ? const Center(
//                       child: Text(
//                         "No booking history yet.",
//                         style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
//                       ),
//                     )
//                   : ListView.builder(
//                       padding: const EdgeInsets.all(20),
//                       itemCount: history.length,
//                       itemBuilder: (context, index) {
//                         final h = history[index];
//                         final color = getStatusColor(h['status'] ?? 'Unknown');

//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 18),
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(14),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black12,
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 3),
//                               ),
//                             ],
//                             border: Border(
//                               left: BorderSide(
//                                 color: color,
//                                 width: 5,
//                               ),
//                             ),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // 🏢 Room name + building
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Row(children: [
//                                     const Icon(Icons.meeting_room, color: Colors.indigo),
//                                     const SizedBox(width: 6),
//                                     Text(
//                                       h['room'] ?? '',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 17,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                   ]),
//                                   Row(children: [
//                                     const Icon(Icons.location_city, color: Colors.indigo, size: 18),
//                                     const SizedBox(width: 4),
//                                     Text(
//                                       h['building'] ?? '',
//                                       style: const TextStyle(color: Colors.black54, fontSize: 15),
//                                     ),
//                                   ]),
//                                 ],
//                               ),

//                               const SizedBox(height: 12),
//                               const Divider(),
//                               const SizedBox(height: 10),

//                               // 🕒 Time slot
//                               Row(children: [
//                                 const Icon(Icons.access_time, color: Colors.indigo, size: 18),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "Time Slot: ${h['timeslot'] ?? ''}",
//                                   style: const TextStyle(fontSize: 15, color: Colors.black87),
//                                 ),
//                               ]),

//                               const SizedBox(height: 8),

//                               // 📅 Date
//                               Row(children: [
//                                 const Icon(Icons.calendar_today, color: Colors.indigo, size: 18),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   "Date: ${h['date'] ?? ''}",
//                                   style: const TextStyle(fontSize: 15, color: Colors.black87),
//                                 ),
//                               ]),

//                               const SizedBox(height: 12),

//                               // 🧾 Status + Approved By (Improved)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.info_outline, color: Colors.indigo, size: 20),
//                                       const SizedBox(width: 8),
//                                       const Text(
//                                         "Status:",
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.w600,
//                                           fontSize: 15,
//                                           color: Colors.black87,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           color: color.withOpacity(0.15),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                         child: Text(
//                                           h['status'] ?? 'Unknown',
//                                           style: TextStyle(
//                                             color: color,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   if (h['approved_by'] != null &&
//                                       h['approved_by'].toString().isNotEmpty &&
//                                       h['status'] == 'Approved')
//                                     Padding(
//                                       padding: const EdgeInsets.only(left: 30.0, top: 4),
//                                       child: Row(
//                                         children: [
//                                           const Icon(Icons.verified_user, color: Colors.grey, size: 16),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             "Approved by ${h['approved_by']}",
//                                             style: const TextStyle(
//                                               fontStyle: FontStyle.italic,
//                                               fontSize: 13,
//                                               color: Colors.black54,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main.dart';

class StudentHistoryPage extends StatefulWidget {
  final int userId;
  final String username;
  const StudentHistoryPage({super.key, required this.userId, required this.username});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  List<dynamic> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => loading = true);
    final data = await ApiService.getBookings(widget.userId);
    final filtered =
        data.where((b) => (b['status'] == 'Approved' || b['status'] == 'Rejected')).toList();
    setState(() {
      history = filtered;
      loading = false;
    });
  }

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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text(
          'Booking History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
              onRefresh: loadHistory,
              child: history.isEmpty
                  ? const Center(
                      child: Text(
                        "No booking history yet.",
                        style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final h = history[index];
                        final color = getStatusColor(h['status'] ?? 'Unknown');
                        final isApproved = h['status'] == 'Approved';
                        final isRejected = h['status'] == 'Rejected';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(20),
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
                            border: Border(
                              left: BorderSide(
                                color: color,
                                width: 5,
                              ),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🏢 Room name + building
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(children: [
                                    const Icon(Icons.meeting_room, color: Colors.indigo),
                                    const SizedBox(width: 6),
                                    Text(
                                      h['room'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ]),
                                  Row(children: [
                                    const Icon(Icons.location_city, color: Colors.indigo, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      h['building'] ?? '',
                                      style: const TextStyle(color: Colors.black54, fontSize: 15),
                                    ),
                                  ]),
                                ],
                              ),

                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 10),

                              // 🕒 Time slot
                              Row(children: [
                                const Icon(Icons.access_time, color: Colors.indigo, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Time Slot: ${h['timeslot'] ?? ''}",
                                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                              ]),

                              const SizedBox(height: 8),

                              // 📅 Date
                              Row(children: [
                                const Icon(Icons.calendar_today, color: Colors.indigo, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "Date: ${h['date'] ?? ''}",
                                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                                ),
                              ]),

                              const SizedBox(height: 12),

                              // 🧾 Status + Approved/Rejected By
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: Colors.indigo, size: 20),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "Status:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        child: Text(
                                          h['status'] ?? 'Unknown',
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // 👇 Rejected by / Approved by section
                                  if (h['approved_by'] != null &&
                                      h['approved_by'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30.0, top: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isApproved
                                                ? Icons.verified_user
                                                : Icons.block,
                                            color: isApproved ? Colors.green : Colors.red,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${isApproved ? 'Approved' : 'Rejected'} by ${h['approved_by']}",
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 13,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
