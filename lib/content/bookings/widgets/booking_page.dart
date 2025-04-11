import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingPage extends StatelessWidget {
  final int bookingIndex;

  const BookingPage({super.key, required this.bookingIndex});

  Widget _buildHeader(Booking booking) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        booking.title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQRCode(Booking booking) {
    return QrImageView(
      data: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      version: QrVersions.auto,
      size: 200.0,
    );
  }

  Widget _buildBookingDetails(Booking booking) {
    return Column(
      children: [
        ListTile(subtitle: Text(booking.description)),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text("Date"),
          subtitle: Text(
            DateFormat.MMMMEEEEd().format(booking.startTime!).toString(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text("Time"),
          subtitle: Text(
            "${DateFormat.jm().format(booking.startTime!)} - ${DateFormat.jm().format(booking.endTime!)}",
          ),
        ),
        ListTile(
          leading: const Icon(Icons.location_on),
          title: const Text("Location"),
          subtitle: Text('${booking.gymName} - ${booking.room}'),
        ),
        ListTile(
          leading: const Icon(Icons.monetization_on),
          title: const Text("Price"),
          subtitle: Text('${booking.price} EUR'),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(booking.instructorTitle),
          subtitle: Text(booking.instructorName),
        ),
      ],
    );
  }

  Widget _buildBookingActions(Booking booking) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Logic to add the booking to the calendar
            },
            icon: const Icon(Icons.calendar_today),
            label: const Text("Add to Calendar"),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {
              // Logic to cancel the booking
            },
            icon: const Icon(Icons.cancel, color: Colors.white),
            label: const Text(
              "Cancel Booking",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTicket(Booking booking) {
    return Column(
      children: [
        _buildHeader(booking),
        _buildQRCode(booking),
        _buildBookingDetails(booking),
        _buildBookingActions(booking),
      ],
    );
  }

  Widget _buildDesktopTicket(Booking booking) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildHeader(booking), _buildBookingDetails(booking)],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: Column(
            children: [_buildQRCode(booking), _buildBookingActions(booking)],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Booking booking = context.watch<BookingsProvider>().bookings![bookingIndex];
    bool useMobileLayout = context.watch<ScreenProvider>().useMobileLayout;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding:
                useMobileLayout
                    ? const EdgeInsets.all(20.0)
                    : const EdgeInsets.symmetric(
                      horizontal: 60.0,
                      vertical: 20.0,
                    ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child:
                  useMobileLayout
                      ? _buildMobileTicket(booking)
                      : _buildDesktopTicket(booking),
            ),
          ),
        ),
      ),
    );
  }
}
