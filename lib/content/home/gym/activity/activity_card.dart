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
    // Check if the SlotProvider is already provided in the widget tree
    // If not, create a new instance of SlotProvider
    // and push the BookSlotPage onto the navigation stack
    // using the provided gymId and activityId
    // This is useful for testing purposes

    bool hasSlotProvider = false;
    try {
      context.read<SlotProvider>();
      hasSlotProvider = true;
    } catch (_) {
      // Provider doesn't exist, we'll create a new one
    }

    if (hasSlotProvider) {
      // SlotProvider exists, just navigate
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => BookSlotPage(
                gymIndex: gymIndex,
                activityIndex: activityIndex,
              ),
        ),
      );
    } else {
      // SlotProvider doesn't exist, create a new instance
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChangeNotifierProvider(
                create:
                    (_) => SlotProvider(gymId: gymId, activityId: activityId),
                child: BookSlotPage(
                  gymIndex: gymIndex,
                  activityIndex: activityIndex,
                ),
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];
    Activity activity = gym.activities[activityIndex];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateToBookSlotPage(context, gym.id!, activity.id),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Colors.blue, // You can change the color as needed
                  width: 4.0, // Adjust the width as desired
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Icon(Icons.calendar_month_outlined),
                    ),
                    Text(activity.title),
                  ],
                ),
                Icon(Icons.arrow_forward_ios_outlined, size: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
