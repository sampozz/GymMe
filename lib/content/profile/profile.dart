import 'package:dima_project/content/profile/my_data.dart';
import 'package:dima_project/content/profile/subscription/subscriptions.dart';
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
  void _signOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
  }

  void onToggleTheme() {
    // Implement theme toggle logic here
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
                                Icon(Icons.check_circle, color: Colors.white),
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
                                Icon(Icons.check_circle, color: Colors.white),
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
    final List<String> fields = <String>[
      "Chip", // case 0
      "My data", // case 1
      "Subscriptions", // case 2
      "Logout", // case 3
      "Delete account", // case 4
    ];
    final DateTime today = DateTime.now();
    final bool isExpired =
        user?.certificateExpDate != null
            ? user!.certificateExpDate!.isBefore(today)
            : false;

    final bool isDark = false; // Replace with actual theme check

    return user == null
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < fields.length; i++) ...[
                // Salta il tile delle sottoscrizioni se l'utente è admin
                if (!(i == 2 && user.isAdmin))
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      switch (i) {
                        case 0: // "Chip"
                          break;
                        case 1: // "My data"
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => MyData()),
                          );
                          break;
                        case 2: // "Subscriptions"
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Subscriptions(),
                            ),
                          );
                          break;
                        case 3: // "Logout"
                          _signOutConfirm(context);

                          break;
                        case 4: // Delete account
                          _deleteAccountConfirm(user);
                          break;
                      }
                    },
                    child:
                        i == 0
                            ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                                vertical: 8.0,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 10.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              user.photoURL.isEmpty
                                                  ? AssetImage(
                                                    'assets/avatar.png',
                                                  )
                                                  : NetworkImage(user.photoURL),
                                          radius: 40,
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.displayName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                user.email,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          transitionBuilder:
                                              (child, animation) =>
                                                  RotationTransition(
                                                    turns: animation,
                                                    child: child,
                                                  ),
                                          child: IconButton(
                                            key: ValueKey(isDark),
                                            icon: Icon(
                                              isDark
                                                  ? Icons.nightlight_round
                                                  : Icons.wb_sunny,
                                            ),
                                            onPressed: onToggleTheme,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!user.isAdmin) ...[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 16.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8.0,
                                              ),
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color:
                                                      user.certificateExpDate !=
                                                              null
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
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              user.certificateExpDate != null
                                                  ? '${user.certificateExpDate!.day}/${user.certificateExpDate!.month}/${user.certificateExpDate!.year}'
                                                  : 'Unspecified',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            )
                            : i == fields.length - 1
                            ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 38.0,
                                vertical: 12.0,
                              ),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  fields[i],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                    decorationColor:
                                        Theme.of(context).primaryColor,
                                    decorationThickness: 1,
                                  ),
                                ),
                              ),
                            )
                            : Padding(
                              // Altri elementi - Mantieni il codice esistente
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Container(
                                height: 50,
                                width: double.infinity,
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                  vertical: 4.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      fields[i],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal,
                                        color:
                                            i == fields.length - 1
                                                ? Colors.red
                                                : i ==
                                                    4 // Logout item
                                                ? Colors.red
                                                : null,
                                      ),
                                    ),
                                    // Sostituisci questa condizione
                                    if (i == 3) // Logout item
                                      Icon(
                                        Icons.logout,
                                        size: 20,
                                        color: Colors.red,
                                      )
                                    else if (i > 0 && i < fields.length - 1)
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                  ),
              ],
              SizedBox(height: 100),
            ],
          ),
        );
  }
}
