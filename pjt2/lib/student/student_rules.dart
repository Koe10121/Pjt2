
import 'package:flutter/material.dart';

class ReservationRulesDialog extends StatelessWidget {
  const ReservationRulesDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Reservation Rules for Students",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("1. Bookings are for today only.\n"),
            Text(
              "You can book a room for the current day, not for future dates.\n",
            ),
            Text("2. Expired slots are disabled.\n"),
            Text(
              "Any time slot that has already passed will automatically be unavailable.\n",
            ),
            Text("3. One booking per student per day.\n"),
            Text("You can reserve only one time slot per day.\n"),
            Text("4. Pending slots are locked.\n"),
            Text(
              "Once a slot is booked and marked as Pending, it cannot be booked by others.\n",
            ),
            Text("5. New day, new availability.\n"),
            Text(
              "All rooms reset to Free or Disabled every new day.\n",
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Understand"),
        ),
      ],
    );
  }
}
