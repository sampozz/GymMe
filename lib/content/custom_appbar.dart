import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;

  const CustomAppBar({super.key, this.user});

  Widget _buildProfileSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(
              (user == null || user!.photoURL.isEmpty)
                  ? 'assets/avatar.png'
                  : user!.photoURL,
            ),
            radius: 20,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome back,', style: TextStyle(fontSize: 16)),
              Text(
                user?.displayName ?? '',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
        child: IconButton(
          icon: Icon(Icons.notifications_outlined),
          onPressed: () {
            // Handle notification icon click
            print('Notification icon clicked');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildProfileSummary(context),
        _buildNotificationsButton(context),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(200);
}
