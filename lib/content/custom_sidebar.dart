import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomSidebar extends StatelessWidget {
  final List pages;
  final int currentIndex;
  final Function(int) onTapCallback;
  final GlobalKey<NavigatorState>? navigatorKey;

  const CustomSidebar({
    super.key,
    required this.pages,
    required this.currentIndex,
    required this.onTapCallback,
    this.navigatorKey,
  });

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Center(
        child: Text(
          'App Logo',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  Widget _buildItemsTitle(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Pages',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    User? user = context.watch<UserProvider>().user;

    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage:
                user?.photoURL.isEmpty ?? true
                    ? AssetImage('assets/avatar.png')
                    : NetworkImage(user?.photoURL ?? ''),
            radius: 20,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              Text(
                user?.email ?? '',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: double.infinity,
        width: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 200),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildItemsTitle(context),
            ...pages.map((page) {
              return SidebarItem(
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
            Expanded(child: Container()),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }
}

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final Function onTapCallback;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTapCallback,
  });

  @override
  State<SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTapCallback(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color:
                widget.isSelected || _isHovered
                    ? Colors.white.withAlpha(20)
                    : Colors.transparent,
          ),
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: widget.isSelected ? Colors.white : Colors.white70,
              ),
              SizedBox(width: 15),
              Text(
                widget.title,
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : Colors.white70,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
