import 'package:dima_project/content/custom_appbar.dart';
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
  final Gym gym;

  const GymPage({super.key, required this.gym});

  /// Navigate to the new gym page
  void _modifyGym(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewGym(gym: gym)),
    );
  }

  /// Navigate to the new activity page
  void _addActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewActivity(gym: gym, activity: null),
      ),
    );
  }

  /// Delete the gym from the database
  Future<void> _deleteGym(BuildContext context) async {
    // TODO: add confirmation dialog
    await Provider.of<GymProvider>(context, listen: false).removeGym(gym);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;

    // TODO: create gym page
    return Scaffold(
      appBar: CustomAppBar(title: "Gym"),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the gym ${gym.name}!'),
            Text('Activities:'),
            ...gym.activities.map(
              (activity) => ActivityCard(gym: gym, activity: activity),
            ),
            if (user?.isAdmin ?? false)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => _addActivity(context),
                    child: Text('Add Activity'),
                  ),
                  ElevatedButton(
                    onPressed: () => _modifyGym(context),
                    child: Text('Modify gym'),
                  ),
                  ElevatedButton(
                    onPressed: () => _deleteGym(context),
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
