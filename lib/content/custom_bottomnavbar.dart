import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final List pages;
  final int currentIndex;
  final Function(int) onTapCallback;

  const CustomBottomNavBar({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onTapCallback,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: customize nav bar
    return BottomNavigationBar(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      currentIndex: currentIndex,
      onTap: onTapCallback,
      items:
          pages.map((p) {
            return BottomNavigationBarItem(
              icon: Icon(p["icon"]),
              label: p["title"],
            );
          }).toList(),
    );
  }
}
