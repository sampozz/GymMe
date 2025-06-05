import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';

class GymBottomSheet extends StatelessWidget {
  final String gymId;

  const GymBottomSheet({super.key, required this.gymId});

  void _onFavoriteIconTap(
    BuildContext context,
    String gymId,
    bool isFavourite,
  ) {
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

  String _formatTime(DateTime time) {
    final hour =
        time.hour == 0
            ? 12
            : time.hour > 12
            ? time.hour - 12
            : time.hour;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final gymProvider = context.watch<GymProvider>();
    final gymList = gymProvider.gymList;
    final gym = gymList!.firstWhere((gym) => gym.id == gymId);
    final gymIndex = gymProvider.getGymIndex(gym);

    final isFavourite = context.watch<UserProvider>().isGymInFavourites(
      gym.id!,
    );

    final String openingTime = _formatTime(gym.openTime!);
    final String closingTime = _formatTime(gym.closeTime!);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Indicator
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Gym Name
                Expanded(
                  child: Text(
                    gym.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Visit Button
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GymPage(gymIndex: gymIndex),
                          ),
                        );
                      },
                      child: Text(
                        'Visit',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Favourite Button
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: Size(40, 40),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed:
                          () =>
                              _onFavoriteIconTap(context, gym.id!, isFavourite),
                      child: Icon(
                        isFavourite ? Icons.favorite : Icons.favorite_border,
                        color: Color(0xFFFB5C1C),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gym Details
          Container(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Gym Address
                    Row(
                      children: [
                        Text(
                          gym.address,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    // Gym Status
                    Row(
                      spacing: 4.0,
                      children: [
                        Text(
                          _isOpen(gym) ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: _isOpen(gym) ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.circle,
                          size: 2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        Text(
                          _isOpen(gym)
                              ? 'Close at $closingTime'
                              : 'Open at $openingTime',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Gym Image
          !kIsWeb && !Platform.isAndroid && !Platform.isIOS
              ? Image.asset('assets/avatar.png', fit: BoxFit.cover) // For tests
              : ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: kIsWeb ? Radius.circular(16) : Radius.circular(0),
                ),
                child: Image.network(
                  gym.imageUrl,
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/gym.jpeg',
                      fit: BoxFit.fitWidth,
                      height: 150,
                      width: double.infinity,
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
