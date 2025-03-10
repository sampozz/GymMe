import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/book_slot_page.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivityCard extends StatelessWidget {
  final Gym gym;
  final Activity activity;

  const ActivityCard({super.key, required this.gym, required this.activity});

  /// Navigates to the book slot page when an activity card is tapped
  void _navigateToBookSlotPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChangeNotifierProvider(
              create: (context) => SlotProvider(gym: gym, activity: activity),
              child: BookSlotPage(gym: gym, activity: activity),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Customize the card with more information
    return GestureDetector(
      onTap: () => _navigateToBookSlotPage(context),
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
