import 'package:gymme/content/profile/my_data.dart';
import 'package:gymme/content/profile/subscription/subscriptions.dart';
import 'package:gymme/providers/theme_provider.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String get _currentThemeMode =>
      Provider.of<ThemeProvider>(context, listen: false).currentThemeMode;

  void _signOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
  }

  void onCycleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).cycleTheme();
    setState(() {});
  }

  void _deleteAccountConfirm(User user) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder:
          (ctx) => SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to cancel the account?",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      context.read<UserProvider>().deleteAccount(user.uid);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text('User deleted successfully!'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    label: const Text("Confirm deletion"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _signOutConfirm(BuildContext context) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder:
          (ctx) => SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Are you sure you want to logout?",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      _signOut(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(width: 12),
                              Expanded(child: Text('Logged out successfully!')),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                      if (ctx.mounted) {
                        Navigator.of(ctx).pop();
                      }
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    label: const Text("Confirm logout"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;
    final DateTime today = DateTime.now();
    final bool isExpired =
        user?.certificateExpDate != null
            ? user!.certificateExpDate!.isBefore(today)
            : false;

    if (user == null) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildUserProfileCard(user, isExpired),

          // My Data option
          _buildNavigationTile(
            "My data",
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyData()),
                ),
          ),

          // Subscriptions (only for non-admin users)
          if (!user.isAdmin)
            _buildNavigationTile(
              "Subscriptions",
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Subscriptions()),
                  ),
            ),

          // Logout option
          _buildNavigationTile(
            "Logout",
            isLogout: true,
            onTap: () => _signOutConfirm(context),
          ),

          // Delete account option
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 38.0,
              vertical: 12.0,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _deleteAccountConfirm(user),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Delete account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 100),
        ],
      ),
    );
  }

  // User Profile Card
  Widget _buildUserProfileCard(User user, bool isExpired) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30.0,
        left: 20.0,
        right: 20.0,
        bottom: 10.0,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: ClipOval(
                    child:
                        !kIsWeb && !Platform.isAndroid && !Platform.isIOS
                            ? Image.asset(
                              'assets/avatar.png',
                              fit: BoxFit.cover,
                            ) // For tests
                            : Image.network(
                              user.photoURL,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) {
                                return Image.asset('assets/avatar.png');
                              },
                            ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        user.displayName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildThemeToggleButton(),
              ],
            ),
            if (!user.isAdmin) ...[
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color:
                              user.certificateExpDate != null
                                  ? isExpired
                                      ? Colors.red
                                      : Colors.green
                                  : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Text(
                      'Medical certificate exp:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      user.certificateExpDate != null
                          ? '${user.certificateExpDate!.day}/${user.certificateExpDate!.month}/${user.certificateExpDate!.year}'
                          : 'Unspecified',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggleButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder:
              (child, animation) =>
                  RotationTransition(turns: animation, child: child),
          child: IconButton(
            key: ValueKey(_currentThemeMode),
            icon: _getThemeIcon(),
            onPressed: onCycleTheme,
            tooltip: 'Theme: $_currentThemeMode',
          ),
        ),
        Text(
          _currentThemeMode,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _getThemeIcon() {
    switch (_currentThemeMode) {
      case 'Auto':
        return Icon(
          Icons.brightness_auto_outlined,
          color: Theme.of(context).colorScheme.primary,
        );
      case 'Light':
        return Icon(
          Icons.wb_sunny_outlined,
          color: Theme.of(context).colorScheme.secondary,
        );
      case 'Dark':
        return Icon(
          Icons.dark_mode_outlined,
          color: Theme.of(context).colorScheme.primary,
        );
      default:
        return Icon(
          Icons.brightness_auto_outlined,
          color: Theme.of(context).colorScheme.primary,
        );
    }
  }

  // Navigation Tile for options
  Widget _buildNavigationTile(
    String title, {
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          height: 50,
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12.0),
          ),
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color:
                      isLogout
                          ? Theme.of(context).colorScheme.errorContainer
                          : null,
                ),
              ),
              isLogout
                  ? Icon(
                    Icons.logout_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.errorContainer,
                  )
                  : Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
