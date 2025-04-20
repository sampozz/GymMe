import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/bookings/widgets/booking_page.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BookingCard extends StatelessWidget {
  final int bookingIndex;

  const BookingCard({super.key, required this.bookingIndex});

  void _navigateToBookingPage(BuildContext context, Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPage(bookingIndex: bookingIndex),
      ),
    );
  }

  Widget _buildLeftColumn(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          booking.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat.jm().format(booking.startTime),
          style: const TextStyle(fontSize: 16),
        ),
        Text(booking.gymName, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  booking.instructorPhoto.isEmpty
                      ? AssetImage('assets/avatar.png')
                      : NetworkImage(booking.instructorPhoto),
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(booking.instructorTitle, style: TextStyle(fontSize: 12)),
                Text(
                  booking.instructorName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightColumn(Booking booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          DateFormat(
            DateFormat.ABBR_WEEKDAY,
          ).format(booking.startTime).toUpperCase(),
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          booking.startTime.day.toString(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          DateFormat.MMMM().format(booking.startTime),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Booking? booking = context
        .watch<BookingsProvider>()
        .bookings!
        .elementAtOrNull(bookingIndex);
    bool useMobileLayout = context.watch<ScreenProvider>().useMobileLayout;
    if (booking == null) {
      return Container(); // Return an empty widget if booking is null
    }

    return GestureDetector(
      onTap: () => _navigateToBookingPage(context, booking),
      child: Padding(
        padding:
            useMobileLayout
                ? const EdgeInsets.all(0)
                : const EdgeInsets.symmetric(horizontal: 60.0),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeftColumn(booking),
                  _buildRightColumn(booking),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
