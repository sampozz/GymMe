import 'package:gymme/models/booking_update_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/content/bookings/booking_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List<BookingUpdate> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    context.read<BookingsProvider>().getBookingUpdates().then((updates) {
      setState(() {
        _notifications = updates;
        _notifications.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        _isLoading = false;
      });
    });
  }

  void _navigateToBookingPage(BookingUpdate notification) {
    int bookingIndex = context.read<BookingsProvider>().getBookingIndex(
      notification.bookingId,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPage(bookingIndex: bookingIndex),
      ),
    );
  }

  void _markAsRead(BookingUpdate notification) {
    setState(() {
      notification.read = true;
    });
    context.read<BookingsProvider>().markUpdateAsRead(notification);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(title: Text('Notifications')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading)
            Center(child: CircularProgressIndicator())
          else if (_notifications.isEmpty)
            Center(child: Text('No notifications available.'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  BookingUpdate notification = _notifications[index];
                  String date = DateFormat(
                    DateFormat.ABBR_MONTH_DAY,
                  ).format(notification.updatedAt);
                  return ListTile(
                    leading:
                        notification.read
                            ? Icon(Icons.check, color: Colors.black54)
                            : GestureDetector(
                              onTap: () => _markAsRead(notification),
                              child: Icon(
                                Icons.circle_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                    title: Text(
                      notification.message,
                      style: TextStyle(
                        fontWeight:
                            notification.read
                                ? FontWeight.normal
                                : FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('($date) Tap to view booking details'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 8),
                    onTap: () => _navigateToBookingPage(notification),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
