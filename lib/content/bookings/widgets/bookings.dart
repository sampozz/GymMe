import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/bookings/widgets/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Bookings extends StatelessWidget {
  const Bookings({super.key});

  Future<void> _refreshBookings(BuildContext context) async {
    await context.read<BookingsProvider>().getBookings().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to refresh bookings"),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return [];
      },
    );
  }

  Widget _buildBookingsList(BuildContext context, List<Booking>? bookings) {
    var bookingsProvider = context.read<BookingsProvider>();

    return switch (bookings) {
      null => const Center(child: CircularProgressIndicator()),
      [] => const Center(child: Text("No bookings available")),
      _ => RefreshIndicator(
        backgroundColor: Theme.of(context).colorScheme.primary,
        color: Colors.white,
        onRefresh: () => _refreshBookings(context),
        child: ListView.builder(
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            Booking booking = bookings[index];
            return BookingCard(
              bookingIndex: bookingsProvider.getBookingIndex(booking.id),
            );
          },
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    List<Booking>? bookings = context.watch<BookingsProvider>().bookings;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: "Upcoming"), Tab(text: "Past")],
            dividerHeight: 0,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          child: TabBarView(
            children: <Widget>[
              Center(
                child: _buildBookingsList(
                  context,
                  bookings
                      ?.where((b) => b.startTime.isAfter(startOfDay))
                      .toList(),
                ),
              ),
              Center(
                child: _buildBookingsList(
                  context,
                  bookings
                      ?.where((b) => b.startTime.isBefore(startOfDay))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
