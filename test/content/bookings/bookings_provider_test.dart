import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../firestore_test.mocks.dart';
import '../../service_test.mocks.dart';

void main() {
  MockBookingsService bookingsService = MockBookingsService();
  MockInstructorService instructorService = MockInstructorService();
  MockFirebaseAuth firebaseAuth = MockFirebaseAuth();

  BookingsProvider bookingsProvider = BookingsProvider(
    bookingsService: bookingsService,
    instructorService: instructorService,
    firebaseAuth: firebaseAuth,
  );

  group('BookingsProvider', () {
    test('Initial bookings should be null', () {
      expect(bookingsProvider.bookings, isNull);
    });

    test('getBookings should fetch bookings', () async {
      List<Booking> mockBookings = [Booking(id: '1')];
      when(
        bookingsService.fetchBookings(),
      ).thenAnswer((_) async => mockBookings);

      final bookings = await bookingsProvider.getBookings();

      expect(bookings, mockBookings);
    });

    test('getTodaysBookings should return bookings for today', () async {
      DateTime now = DateTime.now();
      List<Booking> mockBookings = [
        Booking(id: '1', startTime: now),
        Booking(id: '2', startTime: now.add(Duration(days: 1))),
      ];
      when(
        bookingsService.fetchBookings(),
      ).thenAnswer((_) async => mockBookings);

      final todaysBookings = await bookingsProvider.getTodaysBookings();

      expect(todaysBookings.length, 1);
      expect(todaysBookings[0].id, '1');
    });

    test(
      'createBooking should return false if slot is already booked',
      () async {
        Slot mockSlot = Slot(id: '1', bookedUsers: ['user1'], maxUsers: 2);

        auth.User mockUser = MockUser();
        when(mockUser.uid).thenReturn('user1');
        when(firebaseAuth.currentUser).thenReturn(mockUser);

        final res = await bookingsProvider.createBooking(
          Gym(),
          Activity(),
          mockSlot,
        );

        expect(res, false);
      },
    );

    test(
      'createBooking should create a booking if slot is available',
      () async {
        Slot mockSlot = Slot(id: '1', maxUsers: 2);
        auth.User mockUser = MockUser();
        when(mockUser.uid).thenReturn('user1');
        when(firebaseAuth.currentUser).thenReturn(mockUser);

        Instructor mockInstructor = Instructor(id: 'instructor1');
        when(
          instructorService.fetchInstructorById(any),
        ).thenAnswer((_) async => mockInstructor);

        when(
          bookingsService.addBooking(any, any),
        ).thenAnswer((_) async => 'booking1');

        final res = await bookingsProvider.createBooking(
          Gym(),
          Activity(instructorId: 'instructor1'),
          mockSlot,
        );

        expect(res, true);
      },
    );

    test('removeBooking should remove a booking', () async {
      Booking booking = Booking(id: '1');

      when(bookingsService.fetchBookings()).thenAnswer((_) async => [booking]);

      when(bookingsService.deleteBooking(any)).thenAnswer((_) async => true);

      await bookingsProvider.getBookings();
      await bookingsProvider.removeBooking(booking);

      expect(bookingsProvider.bookings, isEmpty);
    });

    test('getBookingIndex should return the index of a booking', () async {
      Booking booking1 = Booking(id: '1');
      Booking booking2 = Booking(id: '2');

      when(
        bookingsService.fetchBookings(),
      ).thenAnswer((_) async => [booking1, booking2]);

      await bookingsProvider.getBookings();
      int index = bookingsProvider.getBookingIndex('1');

      expect(index, 0);
    });
  });
}
