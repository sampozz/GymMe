import 'package:dima_project/content/profile/my_data.dart';
import 'package:dima_project/content/profile/subscription/subscriptions.dart';
import 'package:dima_project/global_providers/theme_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool get _isDark =>
      Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

  void _signOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
  }

  void onToggleTheme() {
    Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    setState(() {}); // Aggiorna l'UI per mostrare l'icona corretta
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
                      if (mounted) {
                        context.read<UserProvider>().deleteAccount(user.uid);
                      }
                      if (mounted) {
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
                      }
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
                      if (mounted) {
                        _signOut(context);
                      }
                      if (mounted) {
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
                                  child: Text('Logged out successfully!'),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
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
                    child: Image.network(
                      user?.photoURL ?? '',
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
                // Aggiungi qui l'icona animata con AnimatedSwitcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (child, animation) =>
                          RotationTransition(turns: animation, child: child),
                  child: IconButton(
                    key: ValueKey(_isDark), // Importante per l'animazione
                    icon: Icon(
                      _isDark
                          ? Icons.dark_mode_outlined
                          : Icons.wb_sunny_outlined,
                      color:
                          _isDark
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: onToggleTheme,
                  ),
                ),
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
