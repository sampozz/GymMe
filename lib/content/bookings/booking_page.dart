import 'package:gymme/models/booking_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingPage extends StatefulWidget {
  final int bookingIndex;

  const BookingPage({super.key, required this.bookingIndex});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
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
            DateFormat.MMMMEEEEd().format(booking.startTime).toString(),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.access_time),
          title: const Text("Time"),
          subtitle: Text(
            "${DateFormat.jm().format(booking.startTime)} - ${DateFormat.jm().format(booking.endTime)}",
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
          leading: const Icon(Icons.payment),
          title: const Text("Payment Status"),
          subtitle:
              booking.paymentStatus == 'completed'
                  ? const Text("Paid", style: TextStyle(color: Colors.green))
                  : const Text("Pending", style: TextStyle(color: Colors.red)),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(booking.instructorTitle),
          subtitle: Text(booking.instructorName),
        ),
      ],
    );
  }

  void _cancelBooking(Booking booking) {
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
                    "Are you sure you want to cancel this booking?",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () async {
                      context.read<BookingsProvider>().removeBooking(booking);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text("Booking cancelled successfully"),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      Navigator.of(ctx).pop();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text("Confirm Cancellation"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _addToCalendar(Booking booking) {
    context.read<BookingsProvider>().addToCalendar(booking);
  }

  Widget _buildBookingActions(Booking booking) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            onPressed: () => _addToCalendar(booking),
            icon: const Icon(Icons.calendar_today),
            label: const Text("Add to Calendar"),
          ),
          const SizedBox(height: 10),
          if (booking.endTime.isAfter(DateTime.now()))
            TextButton.icon(
              onPressed: () => _cancelBooking(booking),
              icon: const Icon(Icons.cancel, color: Colors.white),
              label: const Text(
                "Cancel Booking",
                style: TextStyle(color: Colors.white),
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.red),
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
    Booking? booking = context
        .watch<BookingsProvider>()
        .bookings!
        .elementAtOrNull(widget.bookingIndex);
    bool useMobileLayout = context.watch<ScreenProvider>().useMobileLayout;

    if (booking == null) {
      return Container();
    }

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
              elevation: 0,
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
