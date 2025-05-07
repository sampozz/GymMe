import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Favourites extends StatelessWidget {
  const Favourites({super.key});

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    Provider.of<UserProvider>(context, listen: false).fetchUser();
    Provider.of<GymProvider>(context, listen: false).getGymList();
  }

  /// Builds the body of the Favourites page
  Widget _buildBody(
    BuildContext context,
    List<Gym>? gymList,
    List<String>? favouriteGymsIds,
  ) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Your favourite gyms',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: gymList.length,
                itemBuilder:
                    (context, index) =>
                        (favouriteGymsIds.contains(gymList[index].id))
                            ? GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => GymPage(gymIndex: index),
                                    ),
                                  ),
                              child: GymCard(
                                gymIndex: index,
                                isFavourite: true,
                              ),
                            )
                            : Container(),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Gym>? gymList = context.watch<GymProvider>().gymList;
    UserProvider userProvider = context.watch<UserProvider>();

    return Scaffold(
      appBar: CustomAppBar(user: userProvider.user),
      body: _buildBody(context, gymList, userProvider.user?.favouriteGyms),
    );
  }
}
