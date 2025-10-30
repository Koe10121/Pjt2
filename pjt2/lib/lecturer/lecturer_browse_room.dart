
import 'package:flutter/material.dart';
import '../main.dart';
import 'lecturer_home.dart'; // for logout()

class LecturerBrowseRoomPage extends StatelessWidget {
  const LecturerBrowseRoomPage({super.key});

  bool isTimePassed(String slotStartTime, String currentTime) {
    List<int> slotParts = slotStartTime.split(":").map(int.parse).toList();
    List<int> currentParts = currentTime.split(":").map(int.parse).toList();
    if (slotParts[0] < currentParts[0]) return true;
    if (slotParts[0] == currentParts[0] && slotParts[1] <= currentParts[1]) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    String currentTime = AppData.nowTime();
    final rooms = AppData.slotStatus.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lecturer - Browse Room"),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        backgroundColor: Colors.grey[300],
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => logout(context))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var r in rooms)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RoomCardViewOnly(
                r,
                AppData.roomBuildings[r] ?? 'Unknown',
                currentTime,
                isTimePassed,
              ),
            ),
        ]),
      ),
    );
  }
}

class _RoomCardViewOnly extends StatelessWidget {
  final String roomName, building, currentTime;
  final bool Function(String, String) isTimePassed;

  const _RoomCardViewOnly(this.roomName, this.building, this.currentTime, this.isTimePassed);

  @override
  Widget build(BuildContext context) {
    final map = AppData.slotStatus[roomName]!;

    Color colorFor(String status, String startTime) {
      if (status == 'Reserved') return Colors.red;
      if (status == 'Pending') return Colors.amber;
      if (status == 'Disabled') return Colors.grey;
      if (status == 'Free') {
        return isTimePassed(startTime, currentTime) ? Colors.grey : Colors.green;
      }
      return Colors.grey;
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
          _SlotBadge("8-10", map['8-10']!, colorFor(map['8-10']!, "8:00")),
          _SlotBadge("10-12", map['10-12']!, colorFor(map['10-12']!, "10:00")),
        ]),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _SlotBadge("13-15", map['13-15']!, colorFor(map['13-15']!, "13:00")),
          _SlotBadge("15-17", map['15-17']!, colorFor(map['15-17']!, "15:00")),
        ]),
      ]),
    );
  }
}

class _SlotBadge extends StatelessWidget {
  final String label, status;
  final Color color;

  const _SlotBadge(this.label, this.status, this.color);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.access_time, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 6),
        Text(status, style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
