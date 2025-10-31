


// import 'package:flutter/material.dart';
// import '../main.dart';
// import 'student_room_dialog.dart';
// import 'student_rules.dart';

// class BrowseRoomPage extends StatefulWidget {
//   const BrowseRoomPage({super.key});

//   @override
//   State<BrowseRoomPage> createState() => _BrowseRoomPageState();
// }

// class _BrowseRoomPageState extends State<BrowseRoomPage> {
//   String todayDate = AppData.todayDate;
//   String currentTime = AppData.nowTime();

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

//   /// ✅ Improved logic:
//   /// A slot becomes "past" 30 minutes before its end time.
//   bool isTimePassed(String slotRange, String currentTime) {
//     final parts = slotRange.split('-').map((e) => int.parse(e)).toList();
//     final endHour = parts[1];
//     int endMinutes = 0;

//     final curParts = currentTime.split(":").map(int.parse).toList();
//     int curH = curParts[0];
//     int curM = curParts[1];

//     int currentTotal = curH * 60 + curM;
//     int endTotal = endHour * 60 + endMinutes;

//     return currentTotal >= (endTotal - 30);
//   }

//   void makeReservation(String room, String building, String timeSlot) {
//     if (AppData.hasActiveBookingToday()) {
//       showDialog(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           title: const Text('Booking Limit Reached'),
//           content: const Text('You already have a booking today (Pending or Approved).'),
//           actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (ctx) => ConfirmBookingDialog(
//         roomName: room,
//         timeSlot: timeSlot,
//         onConfirm: () {
//           Navigator.pop(ctx);
//           setState(() {
//             AppData.makeStudentBooking(room, building, timeSlot);
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Booking confirmed!")),
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final rooms = AppData.slotStatus.keys.map((roomName) {
//       final building = AppData.roomBuildings[roomName] ?? 'Unknown';
//       final map = AppData.slotStatus[roomName]!;
//       final disabled = map.values.every((v) => v == 'Disabled');
//       return {
//         "name": roomName,
//         "building": building,
//         "disabled": disabled,
//       };
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Student - Browse Room"),
//         titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
//         backgroundColor: Colors.grey[300],
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.rule),
//             onPressed: () => showDialog(
//               context: context,
//               builder: (context) => const ReservationRulesDialog(),
//             ),
//           ),
//           IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context)),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(color: Colors.indigo[300], borderRadius: BorderRadius.circular(10)),
//             child: const Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Welcome, Student!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                 SizedBox(height: 4),
//                 Text("MFU room reservation system", style: TextStyle(color: Colors.white)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Row(children: [const Icon(Icons.calendar_today, size: 20), const SizedBox(width: 4), Text(todayDate)]),
//             Row(children: [const Icon(Icons.access_time, size: 20), const SizedBox(width: 4), Text(currentTime)]),
//           ]),
//           const SizedBox(height: 16),
//           for (var r in rooms)
//             Padding(
//               padding: const EdgeInsets.only(bottom: 16),
//               child: RoomCard(
//                 roomName: r["name"] as String,
//                 building: r["building"] as String,
//                 isDisabled: r["disabled"] as bool,
//                 currentTime: currentTime,
//                 isTimePassed: isTimePassed,
//                 onBook: makeReservation,
//               ),
//             ),
//         ]),
//       ),
//     );
//   }
// }

// class RoomCard extends StatelessWidget {
//   final String roomName;
//   final String building;
//   final bool isDisabled;
//   final String currentTime;
//   final bool Function(String, String) isTimePassed;
//   final void Function(String, String, String) onBook;

//   const RoomCard({
//     super.key,
//     required this.roomName,
//     required this.building,
//     required this.isDisabled,
//     required this.currentTime,
//     required this.isTimePassed,
//     required this.onBook,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final map = AppData.slotStatus[roomName]!;

//     Widget buildSlot(String time) {
//       final status = map[time]!;
//       Color color = Colors.green;

//       if (status == "Disabled") color = Colors.grey;
//       if (status == "Pending") color = Colors.amber;
//       if (status == "Reserved") color = Colors.red;

//       final isPast = isTimePassed(time, currentTime);
//       if (status == "Free" && isPast) color = Colors.grey;

//       return TextButton(
//         style: TextButton.styleFrom(
//           backgroundColor: color.withOpacity(0.2),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         ),
//         onPressed: () {
//           if (status == "Free" && !isDisabled && !isPast) {
//             onBook(roomName, building, time);
//           } else if (status == "Free" && isPast) {
//             // 🕒 Custom message for past-time Free slots
//             showDialog(
//               context: context,
//               builder: (ctx) => AlertDialog(
//                 title: const Text("Time Slot Expired"),
//                 content: const Text("This time slot can no longer be reserved."),
//                 actions: [
//                   TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
//                 ],
//               ),
//             );
//           } else {
//             showDialog(context: context, builder: (context) => const RoomUnavailableDialog());
//           }
//         },
//         child: Row(mainAxisSize: MainAxisSize.min, children: [
//           Icon(Icons.access_time, size: 16, color: color),
//           const SizedBox(width: 4),
//           Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
//           const SizedBox(width: 6),
//           Text(status, style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w500)),
//         ]),
//       );
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: Colors.grey[100],
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           Row(children: [const Icon(Icons.meeting_room), const SizedBox(width: 6), Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold))]),
//           Row(children: [const Icon(Icons.location_city, size: 18), const SizedBox(width: 4), Text(building)]),
//         ]),
//         const SizedBox(height: 12),
//         const Divider(thickness: 1),
//         const SizedBox(height: 12),
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           buildSlot("8-10"),
//           buildSlot("10-12"),
//         ]),
//         const SizedBox(height: 8),
//         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//           buildSlot("13-15"),
//           buildSlot("15-17"),
//         ]),
//       ]),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../main.dart';
import 'student_room_dialog.dart';
import 'student_rules.dart';

class BrowseRoomPage extends StatefulWidget {
  const BrowseRoomPage({super.key});

  @override
  State<BrowseRoomPage> createState() => _BrowseRoomPageState();
}

class _BrowseRoomPageState extends State<BrowseRoomPage> {
  String todayDate = AppData.todayDate;
  String currentTime = AppData.nowTime();

  @override
  void initState() {
    super.initState();
    // 🔄 Auto-refresh time & date every 30 seconds
    Future.delayed(Duration.zero, () {
      setState(() {
        currentTime = AppData.nowTime();
        todayDate = AppData.todayDate;
      });
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(() {
        currentTime = AppData.nowTime();
        todayDate = AppData.todayDate;
      });
      return true;
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
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  bool isTimePassed(String slotRange, String currentTime) {
    final parts = slotRange.split('-').map((e) => int.parse(e)).toList();
    final endHour = parts[1];
    int endMinutes = 0;

    final curParts = currentTime.split(":").map(int.parse).toList();
    int curH = curParts[0];
    int curM = curParts[1];

    int currentTotal = curH * 60 + curM;
    int endTotal = endHour * 60 + endMinutes;

    return currentTotal >= (endTotal - 30);
  }

  void makeReservation(String room, String building, String timeSlot) {
    if (AppData.hasActiveBookingToday()) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Booking Limit Reached'),
          content: const Text('You already have a booking today (Pending or Approved).'),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => ConfirmBookingDialog(
        roomName: room,
        timeSlot: timeSlot,
        onConfirm: () {
          Navigator.pop(ctx);
          setState(() {
            AppData.makeStudentBooking(room, building, timeSlot);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Booking confirmed!")),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rooms = AppData.slotStatus.keys.map((roomName) {
      final building = AppData.roomBuildings[roomName] ?? 'Unknown';
      final map = AppData.slotStatus[roomName]!;
      final disabled = map.values.every((v) => v == 'Disabled');
      return {
        "name": roomName,
        "building": building,
        "disabled": disabled,
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Student - Browse Room"),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.rule),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => const ReservationRulesDialog(),
            ),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.indigo[300], borderRadius: BorderRadius.circular(10)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Welcome, Student!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 4),
                Text("MFU room reservation system", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [const Icon(Icons.calendar_today, size: 20), const SizedBox(width: 4), Text(todayDate)]),
            Row(children: [const Icon(Icons.access_time, size: 20), const SizedBox(width: 4), Text(currentTime)]),
          ]),
          const SizedBox(height: 16),
          for (var r in rooms)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: RoomCard(
                roomName: r["name"] as String,
                building: r["building"] as String,
                isDisabled: r["disabled"] as bool,
                currentTime: currentTime,
                isTimePassed: isTimePassed,
                onBook: makeReservation,
              ),
            ),
        ]),
      ),
    );
  }
}

class RoomCard extends StatelessWidget {
  final String roomName;
  final String building;
  final bool isDisabled;
  final String currentTime;
  final bool Function(String, String) isTimePassed;
  final void Function(String, String, String) onBook;

  const RoomCard({
    super.key,
    required this.roomName,
    required this.building,
    required this.isDisabled,
    required this.currentTime,
    required this.isTimePassed,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[roomName]!;

    Widget buildSlot(String time) {
      final status = map[time]!;
      Color color = Colors.green;

      if (status == "Disabled") color = Colors.grey;
      if (status == "Pending") color = Colors.amber;
      if (status == "Reserved") color = Colors.red;

      final isPast = isTimePassed(time, currentTime);
      if (status == "Free" && isPast) color = Colors.grey;

      return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {
          if (status == "Free" && !isDisabled && !isPast) {
            onBook(roomName, building, time);
          } else if (status == "Free" && isPast) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Time Slot Expired"),
                content: const Text("This time slot can no longer be reserved."),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
                ],
              ),
            );
          } else {
            showDialog(context: context, builder: (context) => const RoomUnavailableDialog());
          }
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 4),
          Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text(status, style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w500)),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [const Icon(Icons.meeting_room), const SizedBox(width: 6), Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold))]),
          Row(children: [const Icon(Icons.location_city, size: 18), const SizedBox(width: 4), Text(building)]),
        ]),
        const SizedBox(height: 12),
        const Divider(thickness: 1),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          buildSlot("8-10"),
          buildSlot("10-12"),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          buildSlot("13-15"),
          buildSlot("15-17"),
        ]),
      ]),
    );
  }
}
