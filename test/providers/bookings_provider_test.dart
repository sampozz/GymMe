import 'package:gymme/models/booking_model.dart';
import 'package:gymme/models/booking_update_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/models/activity_model.dart';
import 'package:gymme/models/slot_model.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/models/instructor_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../firestore_test.mocks.dart';
import '../provider_test.mocks.dart';
import '../service_test.mocks.dart';

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
      'createBooking should return null if slot is already booked',
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

        expect(res, null);
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

        expect(res, isA<Booking>());
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

    test('addToCalendar web should call addToCalendar', () async {
      Booking booking = Booking(
        title: 'Gin Tonic pre-workout',
        startTime: DateTime(2025, 5, 7, 13, 19),
        endTime: DateTime(2025, 5, 7, 18, 7),
        gymName: 'GynTonic®',
      );

      String url =
          'https://www.google.com/calendar/render?action=TEMPLATE&text=Gin%20Tonic%20pre-workout&details=Description&dates=20250507T111900/20250507T160700&location=GynTonic%C2%AE';
      MockPlatformService platformService = MockPlatformService();
      when(platformService.isWeb).thenReturn(true);

      BookingsProvider bookingsProvider = BookingsProvider(
        bookingsService: bookingsService,
        instructorService: instructorService,
        firebaseAuth: firebaseAuth,
        platformService: platformService,
      );

      when(bookingsService.addToCalendarWeb(url)).thenReturn(null);

      bookingsProvider.addToCalendar(booking);

      verify(bookingsService.addToCalendarWeb(url)).called(1);
    });

    test('addToCalendar mobile should call addToCalendar', () async {
      Booking booking = Booking(
        title: 'Gin Tonic pre-workout',
        startTime: DateTime(2025, 5, 7, 13, 19),
        endTime: DateTime(2025, 5, 7, 18, 7),
        gymName: 'GynTonic®',
      );

      MockPlatformService platformService = MockPlatformService();
      when(platformService.isWeb).thenReturn(false);

      BookingsProvider bookingsProvider = BookingsProvider(
        bookingsService: bookingsService,
        instructorService: instructorService,
        firebaseAuth: firebaseAuth,
        platformService: platformService,
      );

      when(bookingsService.addToCalendarMobile(any)).thenReturn(null);

      bookingsProvider.addToCalendar(booking);

      verify(bookingsService.addToCalendarMobile(any)).called(1);
    });

    test('getBookingUpdates should return booking updates', () async {
      BookingUpdate bookingUpdate = BookingUpdate(bookingId: '1');
      List<Booking> mockBookings = [
        Booking(id: '1', bookingUpdate: bookingUpdate),
        Booking(id: '2'),
      ];
      when(
        bookingsService.fetchBookings(),
      ).thenAnswer((_) async => mockBookings);

      final updates = await bookingsProvider.getBookingUpdates();

      expect(updates.length, 1);
      expect(updates[0].bookingId, '1');
    });

    test('markUpdateAsRead should mark booking update as read', () async {
      BookingUpdate bookingUpdate = BookingUpdate(bookingId: '1');

      List<Booking> mockBookings = [
        Booking(id: '1', bookingUpdate: bookingUpdate),
        Booking(id: '2'),
      ];
      when(
        bookingsService.fetchBookings(),
      ).thenAnswer((_) async => mockBookings);

      await bookingsProvider.getBookings();

      bookingsProvider.markUpdateAsRead(bookingUpdate);

      expect(bookingsProvider.bookings![0].bookingUpdate!.read, true);
    });
  });
}
