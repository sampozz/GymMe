import 'package:dima_project/content/home/gym/activity/activity_card.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GymPage extends StatelessWidget {
  final int gymIndex;

  const GymPage({super.key, required this.gymIndex});

  /// Navigate to the new gym page
  void _modifyGym(BuildContext context, Gym gym) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewGym(gym: gym)),
    );
  }

  /// Navigate to the new activity page
  void _addActivity(BuildContext context, Gym gym) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewActivity(gym: gym, activity: null),
      ),
    );
  }

  /// Delete the gym from the database
  Future<void> _deleteGym(BuildContext context, Gym gym) async {
    if (context.mounted) {
      Navigator.pop(context);
    }
    // TODO: add confirmation dialog
    await Provider.of<GymProvider>(context, listen: false).removeGym(gym);
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];

    // TODO: create gym page
    return Scaffold(
      appBar: AppBar(title: Text(gym.name)),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the gym ${gym.name}!'),
            Text('Activities:'),
            Expanded(
              child: ListView.builder(
                itemCount: gym.activities.length,
                itemBuilder: (context, index) {
                  return ActivityCard(gymIndex: gymIndex, activityIndex: index);
                },
              ),
            ),
            if (user?.isAdmin ?? false)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _addActivity(context, gym),
                    child: Text('Add Activity'),
                  ),
                  ElevatedButton(
                    onPressed: () => _modifyGym(context, gym),
                    child: Text('Modify gym'),
                  ),
                  ElevatedButton(
                    onPressed: () => _deleteGym(context, gym),
                    child: Text('Delete gym'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
