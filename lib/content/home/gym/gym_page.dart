import 'dart:io';

import 'package:dima_project/content/home/gym/activity/activity_card.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Gym'),
          content: const Text('Are you sure you want to delete this gym?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    // If the user confirmed, delete the gym
    if (confirm == true) {
      await Provider.of<GymProvider>(context, listen: false)
          .removeGym(gym)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Error while deleting gym. Please try again.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildSliverAppBar(BuildContext context, Gym gym) {
    bool useMobileLayout = context.watch<ScreenProvider>().useMobileLayout;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      leading: Container(
        margin: const EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      title:
          useMobileLayout
              ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 7.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(200),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(gym.name),
              )
              : null,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.0),
            bottomRight: Radius.circular(20.0),
            topLeft: useMobileLayout ? Radius.zero : Radius.circular(20.0),
            topRight: useMobileLayout ? Radius.zero : Radius.circular(20.0),
          ),
          child:
              !kIsWeb && !Platform.isAndroid && !Platform.isIOS
                  ? Image.asset(
                    'assets/avatar.png',
                    fit: BoxFit.cover,
                  ) // For tests
                  : Image.network(
                    gym.imageUrl,
                    fit: BoxFit.fitWidth,
                    height: 200,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: LinearProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/gym.jpeg',
                        fit: BoxFit.fitWidth,
                        height: 200,
                        width: double.infinity,
                      );
                    },
                  ),
        ),
      ),
    );
  }

  Widget _buildHeader(Gym gym) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gym.name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(gym.description, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActivityList(BuildContext context, Gym gym, bool isAdmin) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 8.0),
          child: Text(
            'Activities',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ActivityCard(gymIndex: gymIndex, activityIndex: index),
          );
        }, childCount: gym.activities.length),
      ),
      isAdmin
          ? SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () => _addActivity(context, gym),
                child: Text('Add activity'),
              ),
            ),
          )
          : SliverToBoxAdapter(),
    ];
  }

  Widget _buildInformationList(Gym gym) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.location_on),
              title: Text('Address'),
              subtitle: Text(
                gym.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.phone),
              title: Text('Phone'),
              subtitle: Text(gym.phone),
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.access_time),
              title: Text('Opening hours'),
              subtitle: Text(
                '${DateFormat.jm().format(gym.openTime ?? DateTime(0))} - ${DateFormat.jm().format(gym.closeTime ?? DateTime(0))}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAdminActions(BuildContext context, Gym gym, bool isAdmin) {
    if (!isAdmin) return [];

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Admin Actions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextButton(
            onPressed: () => _modifyGym(context, gym),
            child: Text('Modify gym'),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextButton(
            onPressed: () => _deleteGym(context, gym),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete gym', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    Gym gym = context.watch<GymProvider>().gymList![gymIndex];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, gym),
          _buildHeader(gym),
          ..._buildActivityList(context, gym, user?.isAdmin ?? false),
          _buildInformationList(gym),
          // TODO: add regolamento
          // TODO: add prezziario
          ..._buildAdminActions(context, gym, user?.isAdmin ?? false),
        ],
      ),
    );
  }
}
