import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/book_slot_page.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatelessWidget {
  final int gymIndex;
  final int activityIndex;

  const ActivityCard({
    super.key,
    required this.gymIndex,
    required this.activityIndex,
  });

  /// Navigates to the book slot page when an activity card is tapped
  void _navigateToBookSlotPage(
    BuildContext context,
    String gymId,
    String activityId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider<SlotProvider>(
              create: (_) => SlotProvider(gymId: gymId, activityId: activityId),
              child: BookSlotPage(
                gymIndex: gymIndex,
                activityIndex: activityIndex,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];
    Activity activity = gym.activities[activityIndex];

    // TODO: Customize the card with more information
    return GestureDetector(
      onTap: () => _navigateToBookSlotPage(context, gym.id!, activity.id!),
      child: Card(
        child: SizedBox(
          width: 200,
          height: 50,
          child: Center(child: Text(activity.name)),
        ),
      ),
    );
  }
}
