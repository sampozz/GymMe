import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_card.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
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

  /// Deletes the activity from the database
  Future<void> _deleteActivity(BuildContext context) async {
    await Provider.of<GymProvider>(
      context,
      listen: false,
    ).removeActivity(gym, activity);
    if (context.mounted) {
      // TODO: find way to navigate to the activity page with the updated activity list
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Slot>? slotList = context.watch<SlotProvider>().nextSlots;
    User? user = context.watch<UserProvider>().user;

    // TODO: Create activity page
    return Scaffold(
      appBar: AppBar(title: Text('Activity ${activity.name}')),
      body: Center(
        child: Column(
          children: [
            switch (slotList) {
              // Display a loading indicator when the slot list is null
              null => Center(child: CircularProgressIndicator()),
              // Display a message when there are no slots available
              [] => Center(child: Text('No slots available')),
              // Display the slot list
              _ => RefreshIndicator(
                onRefresh: () => _onRefresh(context),
                child: Column(
                  children:
                      slotList.map((slot) => SlotCard(slot: slot)).toList(),
                ),
              ),
            },
            if (user != null && user.isAdmin)
              ElevatedButton(
                onPressed: () => _deleteActivity(context),
                child: Text('Delete Activity'),
              ),
          ],
        ),
      ),
    );
  }
}
