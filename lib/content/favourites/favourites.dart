import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Favourites extends StatelessWidget {
  const Favourites({super.key});

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    Provider.of<UserProvider>(context, listen: false).getFavouriteGyms();
  }

  @override
  Widget build(BuildContext context) {
    List<Gym>? gymList = context.watch<GymProvider>().gymList;
    List<String>? favouriteGymsIds =
        context.watch<UserProvider>().user?.favouriteGyms;

    // TODO: replace CircularProgressIndicator with shimmer effect https://docs.flutter.dev/cookbook/effects/shimmer-loading
    if (favouriteGymsIds == null || gymList == null) {
      return Center(child: CircularProgressIndicator());
    } else if (favouriteGymsIds.isEmpty) {
      return Center(child: Text('No favourite gyms yet'));
    } else {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.blue,
        onRefresh: () => _onRefresh(context),
        child: ListView.builder(
          itemCount: gymList.length,
          itemBuilder:
              (context, index) =>
                  (favouriteGymsIds.contains(gymList[index].id))
                      ? GymCard(gymIndex: index)
                      : Container(),
        ),
      );
    }
  }
}
