import 'package:dima_project/content/home/home.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
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
        "widget": null,
      },
      {
        "title": "Bookings",
        "description": "Bookings page",
        "icon": Icons.calendar_today_outlined,
        "widget": null,
      },
      {
        "title": "Favourites",
        "description": "Favourites page",
        "icon": Icons.favorite_border,
        "widget": null,
      },
      {
        "title": "Profile",
        "description": "Profile page",
        "icon": Icons.person_outline,
        "widget": null,
      },
    ];
  }

  /// Create bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: Colors.white,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      currentIndex: _currentIndex,
      selectedItemColor: Colors.green,
      onTap: _navigateTab,
      items:
          _pages.map((p) {
            return BottomNavigationBarItem(
              icon: Icon(p["icon"]),
              label: p["title"],
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen data and assign it to the ScreenProvider
    ScreenProvider screenProvider = context.read<ScreenProvider>();
    screenProvider.screenData = MediaQuery.of(context);

    _createPagesList();

    return Scaffold(
      // Top app bar
      appBar: AppBar(
        title: Text(_pages[_currentIndex]["title"]),
        backgroundColor: Colors.green,
      ),

      // Widget selected in the navigation bar
      body: _pages[_currentIndex]["widget"],

      // Create bottom navigation bar only if the screen is mobile
      bottomNavigationBar:
          screenProvider.useMobileLayout ? _buildBottomNavigationBar() : null,
    );
  }
}
