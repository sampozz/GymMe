import 'package:dima_project/content/bookings/widgets/bookings.dart';
import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/content/custom_bottomnavbar.dart';
import 'package:dima_project/content/favourites/favourites.dart';
import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:dima_project/content/home/home.dart';
import 'package:dima_project/content/profile/profile.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  // Current page of the navigation bar
  int _currentIndex = 0;

  // List of pages to show in the navigation bar
  List _pages = [];

  /// Onclick on the navigation bar, update the state to show the selected page
  void _navigateTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Navigate to the add gym page
  void _navigateToAddGym(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewGym()));
  }

  /// Create list of pages to show in the navigation bar
  void _createPagesList() {
    _pages = [
      {
        "title": "Home",
        "description": "Home page",
        "icon": Icons.home_outlined,
        "widget": Home(),
      },
      {
        "title": "Map",
        "description": "Map page",
        "icon": Icons.map_outlined,
        "widget": null, // TODO: implement map page
      },
      {
        "title": "Bookings",
        "description": "Bookings page",
        "icon": Icons.calendar_today_outlined,
        "widget": Bookings(),
      },
      {
        "title": "Favourites",
        "description": "Favourites page",
        "icon": Icons.favorite_border,
        "widget": Favourites(),
      },
      {
        "title": "Profile",
        "description": "Profile page",
        "icon": Icons.person_outline,
        "widget": Profile(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen data and assign it to the ScreenProvider
    ScreenProvider screenProvider = context.read<ScreenProvider>();
    screenProvider.screenData = MediaQuery.of(context);

    // Get the user data
    User? user = context.watch<UserProvider>().user;

    // TODO: setup internationalization

    _createPagesList();

    return Scaffold(
      // Top app bar
      appBar: CustomAppBar(title: _pages[_currentIndex]["title"]),

      // Widget selected in the navigation bar
      body: _pages[_currentIndex]["widget"],

      // Create bottom navigation bar only if the screen is mobile
      // TODO: Create navbar for wider devices
      bottomNavigationBar:
          screenProvider.useMobileLayout
              ? CustomBottomNavBar(
                pages: _pages,
                currentIndex: _currentIndex,
                onTapCallback: _navigateTab,
              )
              : null,

      // Floating action button to add a gym if the user is an admin
      floatingActionButton:
          user != null && user.isAdmin && _currentIndex == 0
              ? FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => _navigateToAddGym(context),
              )
              : null,
    );
  }
}
