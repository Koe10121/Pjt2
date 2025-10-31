// import 'package:flutter/material.dart';
// import '../main.dart';

// class StudentHistoryPage extends StatefulWidget {
//   const StudentHistoryPage({super.key});

//   @override
//   State<StudentHistoryPage> createState() => _StudentHistoryPageState();
// }

// class _StudentHistoryPageState extends State<StudentHistoryPage> {
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
//       case 'Pending':
//         return Colors.amber;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final history = AppData.studentHistory;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student - History'),
//         titleTextStyle: const TextStyle(
//           color: Colors.black,
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//         ),
//         backgroundColor: Colors.grey[300],
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () => logout(context),
//           ),
//         ],
//       ),
//       body: history.isEmpty
//           ? const Center(
//               child: Text(
//                 "No booking history yet.",
//                 style: TextStyle(color: Colors.black54),
//               ),
//             )
//           : ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: history.length,
//               itemBuilder: (context, index) {
//                 final h = history[index];
//                 final color = getStatusColor(h['status'] ?? 'Unknown');

//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[100],
//                     border: Border.all(color: Colors.grey.shade400),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(children: [
//                             const Icon(Icons.meeting_room),
//                             const SizedBox(width: 6),
//                             Text(h['room'] ?? '',
//                                 style: const TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16)),
//                           ]),
//                           Row(children: [
//                             const Icon(Icons.location_city, size: 18),
//                             const SizedBox(width: 4),
//                             Text(h['building'] ?? ''),
//                           ]),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       const Divider(thickness: 1),
//                       const SizedBox(height: 10),
//                       Row(children: [
//                         const Icon(Icons.access_time, size: 18),
//                         const SizedBox(width: 6),
//                         Text("Time Slot: ${h['timeslot']}"),
//                       ]),
//                       const SizedBox(height: 6),
//                       Row(children: [
//                         const Icon(Icons.calendar_today, size: 18),
//                         const SizedBox(width: 6),
//                         Text("Date: ${h['date']}"),
//                       ]),
//                       const SizedBox(height: 6),
//                       Row(children: [
//                         const Icon(Icons.person, size: 18),
//                         const SizedBox(width: 6),
//                         Text("Approved by: ${h['actionBy'] ?? '-'}"),
//                       ]),
//                       const SizedBox(height: 10),
//                       Row(children: [
//                         const Text("Status: ",
//                             style: TextStyle(fontWeight: FontWeight.w600)),
//                         Container(
//                           decoration: BoxDecoration(
//                             color: color.withOpacity(0.15),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 10, vertical: 4),
//                           child: Text(
//                             h['status'] ?? 'Unknown',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: color,
//                             ),
//                           ),
//                         ),
//                       ]),
//                     ],
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../main.dart';

class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({super.key});

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
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
              AppData.currentUser = null; // clear login
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
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
      case 'Pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AppData.currentUser;
    final username = currentUser?['displayName'] ?? '';

    // ✅ Filter only current student's history
    final history = AppData.studentHistory
        .where((h) => (h['requestedBy'] ?? '').contains(username))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student - History'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                "No booking history yet.",
                style: TextStyle(color: Colors.black54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final h = history[index];
                final color = getStatusColor(h['status'] ?? 'Unknown');

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Icon(Icons.meeting_room),
                            const SizedBox(width: 6),
                            Text(h['room'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ]),
                          Row(children: [
                            const Icon(Icons.location_city, size: 18),
                            const SizedBox(width: 4),
                            Text(h['building'] ?? ''),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Icon(Icons.access_time, size: 18),
                        const SizedBox(width: 6),
                        Text("Time Slot: ${h['timeslot']}"),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.calendar_today, size: 18),
                        const SizedBox(width: 6),
                        Text("Date: ${h['date']}"),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 6),
                        Text("Approved by: ${h['actionBy'] ?? '-'}"),
                      ]),
                      const SizedBox(height: 10),
                      Row(children: [
                        const Text("Status: ",
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        Container(
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          child: Text(
                            h['status'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ]),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
