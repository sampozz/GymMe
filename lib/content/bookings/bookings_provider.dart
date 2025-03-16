import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_service.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:flutter/material.dart';

class BookingsProvider extends ChangeNotifier {
  final BookingsService _bookingsService;
  List<Booking> _bookings = [];

  // Dependency injection, needed for unit testing
  BookingsProvider({BookingsService? bookingsService})
    : _bookingsService = bookingsService ?? BookingsService();

  /// Getter for the bookings. If the list is empty, fetch it from the service.
  List<Booking> get bookings {
    if (_bookings.isEmpty) {
      _bookingsService.fetchBookings();
    }
    return _bookings;
  }

  /// Fetches the bookings for the current user
  Future<List<Booking>> getBookings() async {
    _bookings = await _bookingsService.fetchBookings();
    notifyListeners();
    return _bookings;
  }

  /// Books a slot for the current user
  Future<void> createBooking(User user, Slot slot) async {
    Booking booking = Booking(
      userId: user.uid,
      slotId: slot.id,
      gymId: slot.gym!.id!,
      activityId: slot.activity!.id!,
      title: slot.activity!.name,
      dateTime: slot.start!,
      duration: slot.duration,
    );
    await _bookingsService.addBooking(booking);
    notifyListeners();
  }
}
