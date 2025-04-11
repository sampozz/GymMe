import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:flutter/material.dart';

class SlotCard extends StatelessWidget {
  final Slot slot;

  const SlotCard({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement the slot card
    return Card(
      child: SizedBox(
        width: 400,
        height: 50,
        child: Center(child: Text('Slot ${slot.startTime?.toLocal()}')),
      ),
    );
  }
}
