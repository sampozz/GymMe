import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/confirm_booking_modal.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/new_slot.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_card.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookSlotPage extends StatelessWidget {
  final int gymIndex;
  final int activityIndex;

  const BookSlotPage({
    super.key,
    required this.gymIndex,
    required this.activityIndex,
  });

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    await Provider.of<SlotProvider>(context, listen: false).getUpcomingSlots();
  }

  /// Deletes the activity from the database
  void _deleteActivity(BuildContext context, Gym gym, Activity activity) {
    Provider.of<GymProvider>(
      context,
      listen: false,
    ).removeActivity(gym, activity);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  /// Modify the activity
  void _modifyActivity(BuildContext context, Gym gym, Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewActivity(gym: gym, activity: activity),
      ),
    );
  }

  /// Navigate to the add slot page
  void _addSlot(BuildContext context, Gym gym, Activity activity) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider.value(
              value: context.read<SlotProvider>(),
              child: NewSlot(gymId: gym.id!, activityId: activity.id!),
            ),
      ),
    );
  }

  void _showBookingModal(
    BuildContext context,
    Gym gym,
    Activity activity,
    Slot slot,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      builder:
          (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: context.read<SlotProvider>()),
              ChangeNotifierProvider(create: (_) => BookingsProvider()),
            ],
            child: ConfirmBookingModal(
              gym: gym,
              activity: activity,
              slot: slot,
            ),
          ),
    );
  }

  Widget _buildAdminActions(BuildContext context, Gym gym, Activity activity) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => _addSlot(context, gym, activity),
          child: Text('Add slot'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _modifyActivity(context, gym, activity),
          child: Text('Modify activity'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => _deleteActivity(context, gym, activity),
          child: Text('Delete activity', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];
    Activity activity = gym.activities[activityIndex];
    List<Slot>? slotList = context.watch<SlotProvider>().nextSlots;
    User? user = context.watch<UserProvider>().user;

    // TODO: Create activity page
    return Scaffold(
      appBar: AppBar(title: Text(activity.title!)),
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
                      slotList
                          .map(
                            (slot) => GestureDetector(
                              onTap:
                                  () => _showBookingModal(
                                    context,
                                    gym,
                                    activity,
                                    slot,
                                  ),
                              child: SlotCard(slot: slot),
                            ),
                          )
                          .toList(),
                ),
              ),
            },
            if (user != null && user.isAdmin)
              _buildAdminActions(context, gym, activity),
          ],
        ),
      ),
    );
  }
}
