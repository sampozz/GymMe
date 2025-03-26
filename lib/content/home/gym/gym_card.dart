import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GymCard extends StatelessWidget {
  final int gymIndex;
  final bool isFavourite;

  const GymCard({super.key, required this.gymIndex, required this.isFavourite});

  /// Navigates to the gym page when a gym card is tapped
  void _onGymCardTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GymPage(gymIndex: gymIndex)),
    );
  }

  /// Navigates to the gym page when a gym card is tapped
  void _onFavoriteIconTap(BuildContext context, String gymId) {
    if (isFavourite) {
      context.read<UserProvider>().removeFavouriteGym(gymId);
    } else {
      context.read<UserProvider>().addFavouriteGym(gymId);
    }
  }

  @override
  Widget build(BuildContext context) {
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];

    // TODO: Customize the card with more information
    return GestureDetector(
      onTap: () => _onGymCardTap(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    gym.name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => _onFavoriteIconTap(context, gym.id!),
                    child: Icon(
                      isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: isFavourite ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'This is a description of the gym.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
