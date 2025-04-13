import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_service.dart';
import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_service.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class BookingsProvider extends ChangeNotifier {
  final BookingsService _bookingsService;
  final InstructorService _instructorService;
  List<Booking>? _bookings;

  // Dependency injection, needed for unit testing
  BookingsProvider({BookingsService? bookingsService})
    : _bookingsService = bookingsService ?? BookingsService(),
      _instructorService = InstructorService();

  /// Getter for the bookings. If the list is empty, fetch it from the service.
  List<Booking>? get bookings {
    if (_bookings == null) {
      getBookings();
    }
    return _bookings;
  }

  /// Fetches the bookings for the current user
  Future<List<Booking>?> getBookings() async {
    _bookings = await _bookingsService.fetchBookings();
    notifyListeners();
    return _bookings;
  }

  /// Books a slot for the current user
  Future<void> createBooking(Gym gym, Activity activity, Slot slot) async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    Instructor? instructor = await _instructorService.fetchInstructorById(
      activity.instructorId!,
    );

    Booking booking = Booking(
      userId: user.uid,
      slotId: slot.id,
      gymId: slot.gymId,
      activityId: slot.activityId,
      startTime: slot.startTime!,
      duration: slot.endTime!.difference(slot.startTime!).inMinutes,
      description: activity.description ?? 'Description not available',
      endTime: slot.endTime!,
      gymName: gym.name,
      instructorName: instructor?.name ?? 'Instructor not available',
      instructorPhoto: instructor?.photo ?? '',
      instructorTitle: instructor?.title ?? '',
      price: activity.price ?? 0.0,
      room: slot.room,
      title: activity.title ?? 'Activity not available',
    );
    await _bookingsService.addBooking(booking);

    // Update the bookings list
    _bookings ??= [];
    _bookings!.add(booking);
    notifyListeners();
  }

  int getBookingIndex(String bookingId) {
    return _bookings!.indexWhere((booking) => booking.id == bookingId);
  }
}
