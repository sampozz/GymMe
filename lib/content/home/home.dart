import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    await Provider.of<GymProvider>(context, listen: false).getGymList();
  }

  /// Navigate to the add gym page
  void _navigateToAddGym(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewGym()));
  }

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<UserProvider>().user;
    List<Gym>? gymList = context.watch<GymProvider>().gymList;

    // TODO: sort the gym list by distance
    // TODO: add a search bar to filter the gym list
    // TODO: show next bookings if any
    // TODO: replace CircularProgressIndicator with shimmer effect https://docs.flutter.dev/cookbook/effects/shimmer-loading
    return Scaffold(
      body:
          gymList == null
              // If the gym list is null, show a loading indicator
              ? Center(child: CircularProgressIndicator())
              // If the gym list is not null, show the gym list
              // refresh indicator allows the user to refresh the gym list by pulling down
              : RefreshIndicator(
                color: Colors.white,
                backgroundColor: Colors.blue,
                onRefresh: () => _onRefresh(context),
                child: ListView.builder(
                  itemCount: gymList.length,
                  itemBuilder: (context, index) => GymCard(gymIndex: index),
                ),
              ),
      floatingActionButton:
          // Floating action button to add a gym if the user is an admin
          user != null && user.isAdmin
              ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => _navigateToAddGym(context),
              )
              : null,
    );
  }
}
