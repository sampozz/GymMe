import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class CustomSidebar extends StatelessWidget {
  final List pages;
  final int currentIndex;
  final Function(int) onTapCallback;
  final GlobalKey<NavigatorState> navigatorKey;

  const CustomSidebar({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onTapCallback,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: customize the sidebar theme
    return SidebarX(
      showToggleButton: false,
      controller: SidebarXController(
        selectedIndex: currentIndex,
        extended: true,
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      items:
          pages.map((page) {
            return SidebarXItem(
              label: page["title"],
              icon: page["icon"],
              onTap: () {
                navigatorKey.currentState?.popUntil((route) => route.isFirst);
                onTapCallback(pages.indexOf(page));
              },
            );
          }).toList(),
    );
  }
}
