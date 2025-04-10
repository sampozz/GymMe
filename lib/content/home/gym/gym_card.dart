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

  bool _isOpen(Gym gym) {
    final now = DateTime.now();
    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      gym.openTime?.hour ?? 0,
      gym.openTime?.minute ?? 0,
    );
    final closeTime = DateTime(
      now.year,
      now.month,
      now.day,
      gym.closeTime?.hour ?? 0,
      gym.closeTime?.minute ?? 0,
    );
    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  @override
  Widget build(BuildContext context) {
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];

    return GestureDetector(
      onTap: () => _onGymCardTap(context),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    ),
                    child: Image.network(
                      gym.imageUrl,
                      fit: BoxFit.fitWidth,
                      height: 175,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/gym.jpeg',
                          fit: BoxFit.fitWidth,
                          height: 175,
                          width: double.infinity,
                        );
                      },
                    ),
                  ),

                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.white,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavourite ? Icons.favorite : Icons.favorite_border,
                          color:
                              isFavourite
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => _onFavoriteIconTap(context, gym.id!),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 5, 8, 8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(gym.address, style: TextStyle(fontSize: 12)),
                    SizedBox(height: 5),
                    SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          Icon(
                            Icons.circle,
                            color: _isOpen(gym) ? Colors.green : Colors.red,
                            size: 10,
                          ),
                          SizedBox(width: 5),
                          Text(
                            _isOpen(gym) ? 'Now open' : 'Closed',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
