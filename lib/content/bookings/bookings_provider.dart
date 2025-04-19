import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_service.dart';
import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_service.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<List<Booking>> getTodaysBookings() async {
    if (_bookings == null) {
      await getBookings();
    }
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day + 1);
    return _bookings?.where((booking) {
          return booking.startTime!.isAfter(startOfDay) &&
              booking.startTime!.isBefore(endOfDay);
        }).toList() ??
        [];
  }

  /// Fetches the bookings for the current user
  Future<List<Booking>?> getBookings() async {
    _bookings = await _bookingsService.fetchBookings();
    notifyListeners();
    return _bookings;
  }

  /// Books a slot for the current user
  Future<bool> createBooking(Gym gym, Activity activity, Slot slot) async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    if (slot.bookedUsers.contains(user.uid) ||
        slot.bookedUsers.length >= slot.maxUsers) {
      return false;
    }

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
    String? bookinId = await _bookingsService.addBooking(booking, slot);
    booking.id = bookinId;
    // Update the bookings list
    if (_bookings != null) {
      _bookings!.add(booking);
    }
    notifyListeners();
    return true;
  }

  /// Removes a booking for the current user
  Future<void> removeBooking(Booking booking) async {
    await _bookingsService.deleteBooking(booking);
    _bookings!.removeWhere((element) => element.id == booking.id);
    notifyListeners();
  }

  int getBookingIndex(String bookingId) {
    return _bookings!.indexWhere((booking) => booking.id == bookingId);
  }

  void addToCalendar(Booking booking) {
    if (kIsWeb) {
      final startUtc =
          booking.startTime!
              .toUtc()
              .toIso8601String()
              .replaceAll(':', '')
              .replaceAll('-', '')
              .split('.')
              .first;
      final endUtc =
          booking.endTime!
              .toUtc()
              .toIso8601String()
              .replaceAll(':', '')
              .replaceAll('-', '')
              .split('.')
              .first;

      var url =
          'https://www.google.com/calendar/render?action=TEMPLATE'
          '&text=${Uri.encodeComponent(booking.title)}'
          '&details=${Uri.encodeComponent(booking.description)}'
          '&dates=$startUtc/$endUtc'
          '&location=${Uri.encodeComponent(booking.gymName)}';

      launchUrl(Uri.parse(url));
    }

    final Event event = Event(
      title: booking.title,
      description: booking.description,
      location: booking.gymName,
      startDate: booking.startTime!,
      endDate: booking.endTime!,
      allDay: false,
    );
    Add2Calendar.addEvent2Cal(event);
  }
}
