import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_provider.dart';
import 'package:dima_project/content/home/gym_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    await Provider.of<GymProvider>(context, listen: false).getGymList();
  }

  @override
  Widget build(BuildContext context) {
    List<Gym>? gymList = context.watch<GymProvider>().gymList;

    // TODO: sort the gym list by distance
    // TODO: add a search bar to filter the gym list
    // TODO: show next bookings if any
    // TODO: replace CircularProgressIndicator with shimmer effect https://docs.flutter.dev/cookbook/effects/shimmer-loading
    return gymList == null
        ? Center(child: CircularProgressIndicator())
        : RefreshIndicator(
          color: Colors.white,
          backgroundColor: Colors.blue,
          onRefresh: () => _onRefresh(context),
          child: ListView(
            children: gymList.map((gym) => GymCard(title: gym.name)).toList(),
          ),
        );
  }
}
