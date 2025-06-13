import 'package:gymme/content/custom_appbar.dart';
import 'package:gymme/content/home/gym/gym_card.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/content/home/gym/gym_page.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Favourites extends StatelessWidget {
  const Favourites({super.key});

  /// Refreshes the gym list by fetching it from the provider
  Future<void> _onRefresh(BuildContext context) async {
    var userProvider = Provider.of<UserProvider>(context, listen: false);
    var gymProvider = Provider.of<GymProvider>(context, listen: false);
    var snackBar = ScaffoldMessenger.of(context);

    await userProvider.fetchUser();
    await gymProvider.getGymList().timeout(
      Duration(seconds: 5),
      onTimeout: () {
        snackBar.showSnackBar(
          const SnackBar(
            content: Text("Failed to refresh gyms"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return [];
      },
    );
  }

  /// Builds the body of the Favourites page
  Widget _buildBody(
    BuildContext context,
    List<Gym>? gymList,
    List<String>? favouriteGymsIds,
  ) {
    if (favouriteGymsIds == null || gymList == null) {
      return Center(child: CircularProgressIndicator());
    } else if (favouriteGymsIds.isEmpty) {
      return Center(child: Text('No favourite gyms yet'));
    } else {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
