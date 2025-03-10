import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/content/home/gym/activity/activity_card.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';

class GymPage extends StatelessWidget {
  final Gym gym;

  const GymPage({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    // TODO: create gym page
    return Scaffold(
      appBar: CustomAppBar(title: "Gym"),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the gym ${gym.name}!'),
            Text('Activities:'),
            Column(
              children:
                  gym.activities
                      .map(
                        (activity) =>
                            ActivityCard(gym: gym, activity: activity),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
