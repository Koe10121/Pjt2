// lib/student/student_browse_room.dart
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main.dart';
import 'student_room_dialog.dart';
import 'student_rules.dart';

class BrowseRoomPage extends StatefulWidget {
  final int userId;
  final String username;
  const BrowseRoomPage({super.key, required this.userId, required this.username});

  @override
  State<BrowseRoomPage> createState() => _BrowseRoomPageState();
}

class _BrowseRoomPageState extends State<BrowseRoomPage> {
  String todayDate = AppData.todayDate;
  String currentTime = AppData.nowTime();
  List<dynamic> rooms = [];
  Map<String, dynamic> roomStatuses = {}; // keyed by room id -> timeslot map
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    // auto refresh
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

  Future<void> _loadRooms() async {
    setState(() => loading = true);
    final r = await ApiService.getRooms();
    final statuses = await ApiService.getRoomStatuses(todayDate);
    setState(() {
      rooms = r;
      roomStatuses = statuses; // note: map from backend
      loading = false;
    });
  }

  void logout(BuildContext context) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Confirm Logout'),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () {
          Navigator.pop(ctx);
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }, child: const Text('Logout'))
      ],
    ));
  }

  bool isTimePassed(String slotRange, String currentTime) {
    final parts = slotRange.split('-').map((e) => int.parse(e)).toList();
    final endHour = parts[1];
    final curParts = currentTime.split(":").map(int.parse).toList();
    final currentTotal = curParts[0] * 60 + curParts[1];
    final endTotal = endHour * 60;
    return currentTotal >= (endTotal - 30);
  }

  Future<void> makeReservation(String roomName, String building, String timeSlot, int roomId) async {
    final alreadyBooked = await AppData.hasActiveBookingToday(widget.userId);
    if (alreadyBooked) {
      showDialog(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Booking Limit Reached'),
        content: const Text('You already have a booking today (Pending or Approved).'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ));
      return;
    }

    showDialog(context: context, builder: (ctx) => ConfirmBookingDialog(
      roomName: roomName,
      timeSlot: timeSlot,
      onConfirm: () async {
        Navigator.pop(ctx);
        final res = await ApiService.bookRoom(widget.userId, roomId, timeSlot);
        if (res['ok'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['msg'] ?? "Booking confirmed!")));
          await _loadRooms(); // refresh UI so pending shows
        } else {
          showDialog(context: context, builder: (ctx2) => AlertDialog(
            title: const Text('Cannot Book'),
            content: Text(res['msg'] ?? "Slot unavailable."),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('OK'))],
          ));
        }
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student - Browse Room"),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[300],
        actions: [
          IconButton(icon: const Icon(Icons.rule), onPressed: () => showDialog(context: context, builder: (c) => const ReservationRulesDialog())),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context)),
        ],
      ),
      body: loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.indigo[300], borderRadius: BorderRadius.circular(10)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Welcome, ${widget.username}!", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              const Text("MFU room reservation system", style: TextStyle(color: Colors.white)),
            ]),
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
                roomName: r['name'],
                building: r['building'],
                isDisabled: (r['disabled'] == 1),
                currentTime: currentTime,
                isTimePassed: isTimePassed,
                onBook: (room, building, slot) => makeReservation(room, building, slot, r['id']),
                roomId: r['id'],
                roomStatusesForThisRoom: roomStatuses[r['id'].toString()] ?? {},
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
  final int roomId;
  final Map roomStatusesForThisRoom; // e.g. {'13-15': 'Pending'}

  const RoomCard({
    super.key,
    required this.roomName,
    required this.building,
    required this.isDisabled,
    required this.currentTime,
    required this.isTimePassed,
    required this.onBook,
    required this.roomId,
    required this.roomStatusesForThisRoom,
  });

  @override
  Widget build(BuildContext context) {
    final slots = ["8-10", "10-12", "13-15", "15-17"];

    Widget buildSlot(String time) {
      String status = "Free";
      Color color = Colors.green;

      if (isDisabled) {
        status = "Disabled";
        color = Colors.grey;
      }

      // if backend says reserved/pending for this room-date
      final backendStatus = roomStatusesForThisRoom[time];
      if (backendStatus != null) {
        status = backendStatus as String;
        if (status == 'Pending') color = Colors.amber;
        if (status == 'Approved') color = Colors.red; // we call 'Reserved' but DB uses 'Approved'
      }

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
            showDialog(context: context, builder: (ctx) => AlertDialog(
              title: const Text("Time Slot Expired"),
              content: const Text("This time slot can no longer be reserved."),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
            ));
          } else {
            showDialog(context: context, builder: (context) => const RoomUnavailableDialog());
          }
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.access_time, size: 16, color: color),
          const SizedBox(width: 4),
          Text(time, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 6),
          Text(status == 'Approved' ? 'Reserved' : status, style: TextStyle(color: Colors.indigo[800], fontWeight: FontWeight.w500)),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[100], border: Border.all(color: Colors.grey.shade300)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [const Icon(Icons.meeting_room), const SizedBox(width: 6), Text(roomName, style: const TextStyle(fontWeight: FontWeight.bold))]),
          Row(children: [const Icon(Icons.location_city, size: 18), const SizedBox(width: 4), Text(building)]),
        ]),
        const SizedBox(height: 12),
        const Divider(thickness: 1),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [buildSlot("8-10"), buildSlot("10-12")]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [buildSlot("13-15"), buildSlot("15-17")]),
      ]),
    );
  }
}
