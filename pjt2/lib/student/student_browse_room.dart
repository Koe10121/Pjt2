import 'package:flutter/material.dart';
import '../api_service.dart';
import '../main.dart';
import 'student_room_dialog.dart';
import 'student_rules.dart';

class BrowseRoomPage extends StatefulWidget {
  final int userId;
  final String username;
  const BrowseRoomPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<BrowseRoomPage> createState() => _BrowseRoomPageState();
}

class _BrowseRoomPageState extends State<BrowseRoomPage> {
  String todayDate = AppData.todayDate;
  String currentTime = AppData.nowTime();
  List<dynamic> rooms = [];
  Map<String, dynamic> roomStatuses = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    // Auto-refresh every 30s
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

    // 🧠 Convert backend structure to simplified map for each room
    final Map<String, Map<String, String>> parsedStatuses = {};
    statuses.forEach((id, data) {
      if (data is Map && data['slots'] != null) {
        parsedStatuses[id.toString()] = Map<String, String>.from(data['slots']);
      }
    });

    setState(() {
      rooms = r;
      roomStatuses = parsedStatuses;
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
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
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
    final curParts = currentTime.split(":").map(int.parse).toList();
    final currentTotal = curParts[0] * 60 + curParts[1];
    final endTotal = endHour * 60;
    return currentTotal >= (endTotal - 30);
  }

  Future<void> makeReservation(
    String roomName,
    String building,
    String timeSlot,
    int roomId,
  ) async {
    final alreadyBooked = await AppData.hasActiveBookingToday(widget.userId);
    if (alreadyBooked) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Booking Limit Reached'),
          content: const Text(
            'You already have a booking today (Pending or Approved).',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => ConfirmBookingDialog(
        roomName: roomName,
        timeSlot: timeSlot,
        onConfirm: () async {
          Navigator.pop(ctx);
          final res = await ApiService.bookRoom(
            widget.userId,
            roomId,
            timeSlot,
          );
          if (res['ok'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(res['msg'] ?? "Booking confirmed!")),
            );
            await _loadRooms();
          } else {
            showDialog(
              context: context,
              builder: (ctx2) => AlertDialog(
                title: const Text('Cannot Book'),
                content: Text(res['msg'] ?? "This time slot is unavailable."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx2),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      appBar: AppBar(
        title: const Text(
          "Browse Rooms",
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
            icon: const Icon(Icons.rule, color: Colors.white),
            onPressed: () => showDialog(
              context: context,
              builder: (c) => const ReservationRulesDialog(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRooms,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                          Text(
                            "Welcome, ${widget.username}!",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "MFU Room Reservation System",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                color: Colors.indigo,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                todayDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                color: Colors.indigo,
                                size: 20,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                currentTime,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (var r in rooms)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: RoomCard(
                          roomName: r['name'],
                          building: r['building'],
                          isDisabled: (r['disabled'] == 1),
                          currentTime: currentTime,
                          isTimePassed: isTimePassed,
                          onBook: (room, building, slot) =>
                              makeReservation(room, building, slot, r['id']),
                          roomId: r['id'],
                          roomStatusesForThisRoom:
                              roomStatuses[r['id'].toString()] ?? {},
                        ),
                      ),
                  ],
                ),
              ),
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
  final Map roomStatusesForThisRoom;

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

      // Default FREE colors
      Color borderColor = Colors.green;
      Color bgColor = Colors.green.withOpacity(0.18);
      Color textColor = Colors.black;

      // If room is disabled
      if (isDisabled) {
        status = "Disabled";
        borderColor = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.22);
        textColor = Colors.black;
      }

      // Backend statuses override
      final backendStatus = roomStatusesForThisRoom[time];
      if (backendStatus != null) {
        status = backendStatus;

        if (status == "Pending") {
          borderColor = Colors.amber;
          bgColor = Colors.amber.withOpacity(0.22);
          textColor = Colors.black;
        } else if (status == "Approved") {
          borderColor = Colors.red;
          bgColor = Colors.red.withOpacity(0.20);
          textColor = Colors.black;
        }
      }

      // Expired Free Slot
      final isPast = isTimePassed(time, currentTime);
      if (status == "Free" && isPast) {
        borderColor = Colors.grey;
        bgColor = Colors.grey.withOpacity(0.22);
        textColor = Colors.black;
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: borderColor, width: 1),
            ),
          ),
          onPressed: () {
            if (status == "Free" && !isDisabled && !isPast) {
              onBook(roomName, building, time);
            } else if (status == "Free" && isPast) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Time Slot Expired"),
                  content: const Text(
                    "This time slot can no longer be reserved.",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("OK"),
                    ),
                  ],
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (ctx) => const RoomUnavailableDialog(),
              );
            }
          },
          icon: Icon(Icons.access_time, size: 18, color: borderColor),
          label: Text(
            "$time  •  ${status == 'Approved' ? 'Reserved' : status}",
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.meeting_room, color: Colors.indigo),
                  const SizedBox(width: 6),
                  Text(
                    roomName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.location_city,
                    size: 18,
                    color: Colors.indigo,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    building,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1.2),
          const SizedBox(height: 10),

          // Slots
          Wrap(
            spacing: 10,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: slots.map((slot) => buildSlot(slot)).toList(),
          ),
        ],
      ),
    );
  }
}
