import 'package:gymme/content/bookings/bookings.dart';
import 'package:gymme/content/custom_bottomnavbar.dart';
import 'package:gymme/content/custom_sidebar.dart';
import 'package:gymme/content/favourites/favourites.dart';
import 'package:gymme/content/home/home.dart';
import 'package:gymme/content/profile/profile_page.dart';
import 'package:gymme/content/map/gym_map.dart';
import 'package:gymme/content/profile/subscription/fetch_subscription.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
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
  void _createUserPagesList() {
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
        "widget": ProfilePage(),
      },
    ];
  }

  void _createAdminPagesList() {
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
        "title": "Members",
        "description": "Members page",
        "icon": Icons.edit_note_outlined,
        "widget": FetchSubscription(),
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
        "widget": ProfilePage(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen data and assign it to the ScreenProvider
    ScreenProvider screenProvider = context.read<ScreenProvider>();
    screenProvider.screenData = MediaQuery.of(context);
    User? user = context.watch<UserProvider>().user;

    // TODO: setup internationalization

    if (user?.isAdmin ?? false) {
      _createAdminPagesList();
    } else {
      _createUserPagesList();
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        // Check if the current Navigator can pop
        if (navigatorKey.currentState?.canPop() ?? false) {
          navigatorKey.currentState?.pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            // Sidebar only if the screen is not mobile
            !(screenProvider.useMobileLayout)
                ? CustomSidebar(
                  pages: _pages,
                  currentIndex: _currentIndex,
                  onTapCallback: _navigateTab,
                  navigatorKey: navigatorKey,
                  isLoading: user == null,
                )
                : Container(),
            Expanded(
              child: Navigator(
                key: navigatorKey,
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          backgroundColor: Colors.transparent,
                          // Widget selected in the navigation bar
                          body: Stack(
                            children: [
                              _pages[_currentIndex]["widget"],

                              screenProvider.useMobileLayout
                                  ? Align(
                                    alignment: Alignment.bottomCenter,
                                    child: CustomBottomNavBar(
                                      pages: _pages,
                                      currentIndex: _currentIndex,
                                      onTapCallback: _navigateTab,
                                      navigatorKey: navigatorKey,
                                    ),
                                  )
                                  : Container(),
                            ],
                          ),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
