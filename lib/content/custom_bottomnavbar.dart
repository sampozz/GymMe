import 'package:flutter/material.dart';
import 'dart:ui'; // Import for BackdropFilter

class CustomBottomNavBar extends StatelessWidget {
  final List pages;
  final int currentIndex;
  final Function(int) onTapCallback;
  final GlobalKey<NavigatorState>? navigatorKey;

  const CustomBottomNavBar({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onTapCallback,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(200)),
              color: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 50),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...pages.map((page) {
                  return NavBarItem(
                    icon: page['icon'],
                    title: page['title'],
                    isSelected: pages.indexOf(page) == currentIndex,
                    onTapCallback: () {
                      navigatorKey?.currentState?.popUntil(
                        (route) => route.isFirst,
                      );
                      onTapCallback(pages.indexOf(page));
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavBarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final Function onTapCallback;

  const NavBarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTapCallback,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTapCallback(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color:
                  widget.isSelected || _isHovered
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSecondary,
            ),
            widget.isSelected
                ? Text(
                  widget.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
                : Container(),
          ],
        ),
      ),
    );
  }
}
