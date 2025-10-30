

import 'package:flutter/material.dart';

class RoomUnavailableDialog extends StatelessWidget {
  const RoomUnavailableDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Room Unavailable"),
      content: const Text(
        "You cannot reserve this time slot because it's already reserved, pending, or disabled.",
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("OK"),
        ),
      ],
    );
  }
}

class ConfirmBookingDialog extends StatelessWidget {
  final String roomName;
  final String timeSlot;

  const ConfirmBookingDialog({
    required this.roomName,
    required this.timeSlot,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Request to Book a Room"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Room: $roomName"),
          const SizedBox(height: 6),
          Text("Time Slot: $timeSlot"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Booking confirmed!")),
            );
          },
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
