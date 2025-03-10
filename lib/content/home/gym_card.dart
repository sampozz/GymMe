import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';

class GymCard extends StatelessWidget {
  final Gym gym;

  const GymCard({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    // TODO: Customize the card with more information
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gym.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'This is a description of the gym.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
