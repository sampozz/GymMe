import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_card.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookSlotPage extends StatelessWidget {
  final Gym gym;
  final Activity activity;

  const BookSlotPage({super.key, required this.gym, required this.activity});

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    await Provider.of<SlotProvider>(context, listen: false).getUpcomingSlots();
  }

  @override
  Widget build(BuildContext context) {
    List<Slot>? slotList = context.watch<SlotProvider>().nextSlots;

    // TODO: Create activity page
    return Scaffold(
      appBar: AppBar(title: Text('Activity ${activity.name}')),
      body: switch (slotList) {
        // Display a loading indicator when the slot list is null
        null => Center(child: CircularProgressIndicator()),
        // Display a message when there are no slots available
        [] => Center(child: Text('No slots available')),
        // Display the slot list
        _ => RefreshIndicator(
          onRefresh: () => _onRefresh(context),
          child: ListView(
            children: slotList.map((slot) => SlotCard(slot: slot)).toList(),
          ),
        ),
      },
    );
  }
}
