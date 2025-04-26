import 'dart:io';

import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/notifications/notifications.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;

  const CustomAppBar({super.key, this.user});

  Widget _buildProfileSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            child:
                !kIsWeb && !Platform.isAndroid && !Platform.isIOS
                    ? Image.asset(
                      'assets/avatar.png',
                      fit: BoxFit.cover,
                    ) // For tests
                    : ClipOval(
                      child: Image.network(
                        user?.photoURL ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) {
                          return Image.asset(
                            'assets/avatar.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
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

  Widget _buildNotificationsButton(
    BuildContext context,
    bool notificationsAvailable,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black),
            ),
            child: IconButton(
              icon: Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Notifications()),
                );
              },
            ),
          ),
          if (notificationsAvailable)
            Positioned(
              left: 1,
              top: 1,
              child: Icon(
                Icons.circle,
                size: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Booking>? bookings = context.watch<BookingsProvider>().bookings;
    bool notificationsAvailable = false;
    if (bookings != null) {
      notificationsAvailable = bookings.any(
        (booking) =>
            booking.bookingUpdate != null && !booking.bookingUpdate!.read,
      );
    }

    return SafeArea(
      child: SizedBox(
        height: kToolbarHeight + 30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildProfileSummary(context),
            _buildNotificationsButton(context, notificationsAvailable),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 30);
}
