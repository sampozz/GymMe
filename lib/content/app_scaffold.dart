import 'package:dima_project/content/bookings/widgets/bookings.dart';
import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/content/custom_bottomnavbar.dart';
import 'package:dima_project/content/custom_sidebar.dart';
import 'package:dima_project/content/favourites/favourites.dart';
import 'package:dima_project/content/home/home.dart';
import 'package:dima_project/content/profile/profile.dart';
import 'package:dima_project/content/map/gym_map.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
        "widget": GymMap(),
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

    // TODO: setup internationalization

    _createPagesList();

    return Row(
      children: [
        // Sidebar only if the screen is not mobile
        !(screenProvider.useMobileLayout)
            ? CustomSidebar(
              pages: _pages,
              currentIndex: _currentIndex,
              onTapCallback: _navigateTab,
              navigatorKey: navigatorKey,
            )
            : Container(),
        Expanded(
          child: Navigator(
            key: navigatorKey,
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      // Top app bar
                      appBar: CustomAppBar(
                        title: _pages[_currentIndex]["title"],
                      ),

                      // Widget selected in the navigation bar
                      body: _pages[_currentIndex]["widget"],

                      // Create bottom navigation bar only if the screen is mobile
                      bottomNavigationBar:
                          screenProvider.useMobileLayout
                              ? CustomBottomNavBar(
                                pages: _pages,
                                currentIndex: _currentIndex,
                                onTapCallback: _navigateTab,
                              )
                              : null,
                    ),
              );
            },
          ),
        ),
      ],
    );
  }
}
