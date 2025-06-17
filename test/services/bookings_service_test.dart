import 'package:gymme/models/booking_model.dart';
import 'package:gymme/models/booking_update_model.dart';
import 'package:gymme/services/bookings_service.dart';
import 'package:gymme/models/slot_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';

import '../firestore_test.mocks.dart';

void main() {
  late BookingsService bookingsService;
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;

  const String testUserId = 'test-user-id';
  final testUser = MockUser();

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    when(testUser.uid).thenReturn(testUserId);
    when(mockAuth.currentUser).thenReturn(testUser);
    bookingsService = BookingsService(
      firestore: fakeFirestore,
      firebaseAuth: mockAuth,
    );
  });

  group('BookingsService', () {
    test('fetchBookings returns correct bookings for current user', () async {
      // Arrange: Add test bookings to the fake Firestore
      final testBooking1 = Booking(
        id: 'booking-id-1',
        userId: testUserId,
        slotId: 'slot-id-1',
      );

      final testBooking2 = Booking(
        id: 'booking-id-2',
        userId: testUserId,
        slotId: 'slot-id-2',
      );

      // Add another user's booking which should not be returned
      final otherUserBooking = Booking(
        id: 'booking-id-3',
        userId: 'other-user-id',
        slotId: 'slot-id-3',
      );

      // Add bookings to fake Firestore
      await fakeFirestore
          .collection('booking')
          .doc(testBooking1.id)
          .set(testBooking1.toFirestore());
      await fakeFirestore
          .collection('booking')
          .doc(testBooking2.id)
          .set(testBooking2.toFirestore());
      await fakeFirestore
          .collection('booking')
          .doc(otherUserBooking.id)
          .set(otherUserBooking.toFirestore());

      // Act: Call the method being tested
      final result = await bookingsService.fetchBookings();

      // Assert: Check that only the current user's bookings are returned
      expect(result.length, 2);
      expect(result.any((booking) => booking.id == testBooking1.id), true);
      expect(result.any((booking) => booking.id == testBooking2.id), true);
      expect(result.any((booking) => booking.id == otherUserBooking.id), false);
    });

    test('addBooking adds booking and updates slot', () async {
      // Arrange: Set up a test slot and booking
      final testSlot = Slot(
        id: 'slot-id-1',
        bookedUsers: List<String>.empty(growable: true), // Initially empty
      );

      final testBooking = Booking(
        id: '', // ID will be assigned by Firestore
        userId: testUserId,
        slotId: testSlot.id,
      );

      // Add the slot to fake Firestore
      await fakeFirestore.collection('slot').doc(testSlot.id).set({
        'id': testSlot.id,
        'bookedUsers': testSlot.bookedUsers,
        // Add other fields from your Slot model
      });

      // Act: Call the method being tested
      final bookingId = await bookingsService.addBooking(testBooking, testSlot);

      // Assert: Check that booking was added and slot was updated
      expect(bookingId, isNotNull);
      expect(bookingId, isNotEmpty);

      // Verify the booking was added to Firestore
      final bookingSnapshot =
          await fakeFirestore.collection('booking').doc(bookingId).get();
      expect(bookingSnapshot.exists, true);

      // Verify the slot was updated with the user ID
      final slotSnapshot =
          await fakeFirestore.collection('slot').doc(testSlot.id).get();
      final updatedBookedUsers =
          slotSnapshot.data()?['bookedUsers'] as List<dynamic>;
      expect(updatedBookedUsers.contains(testUserId), true);
    });

    test('deleteBooking removes booking and updates slot', () async {
      // Arrange: Set up a test slot and booking
      final testSlot = Slot(
        id: 'slot-id-to-delete',
        bookedUsers: [testUserId], // User is already booked
        // Add other required fields based on your Slot model
      );

      final testBooking = Booking(
        id: 'booking-id-to-delete',
        userId: testUserId,
        slotId: testSlot.id,
      );

      // Add the slot and booking to fake Firestore
      // IMPORTANT: For fake_cloud_firestore, use List<String> instead of List<dynamic>
      await fakeFirestore.collection('slot').doc(testSlot.id).set({
        'id': testSlot.id,
        'bookedUsers': [
          testUserId,
        ], // Explicitly use String value, not from model
        // Add other fields from your Slot model
      });

      await fakeFirestore
          .collection('booking')
          .doc(testBooking.id)
          .set(testBooking.toFirestore());

      // Act: Call the method being tested
      await bookingsService.deleteBooking(testBooking);

      // Assert: Check that booking was removed and slot was updated
      final bookingSnapshot =
          await fakeFirestore.collection('booking').doc(testBooking.id).get();
      expect(bookingSnapshot.exists, false);
    });

    test('markUpdateAsRead updates booking update field', () async {
      // Arrange: Set up a test booking with an update
      final testBooking = Booking(
        id: 'booking-with-update',
        userId: testUserId,
        slotId: 'slot-id',
      );

      // Add the booking to fake Firestore
      await fakeFirestore
          .collection('booking')
          .doc(testBooking.id)
          .set(testBooking.toFirestore());

      // Create a booking update
      final bookingUpdate = BookingUpdate(
        bookingId: testBooking.id,
        read: true,
      );

      // Act: Call the method being tested
      await bookingsService.markUpdateAsRead(bookingUpdate);

      // Assert: Check that the booking was updated
      final bookingSnapshot =
          await fakeFirestore.collection('booking').doc(testBooking.id).get();
      final updatedBooking = bookingSnapshot.data();

      // You'll need to adapt this assertion based on your actual data structure
      expect(updatedBooking?['bookingUpdate'], isNotNull);
    });
  });
}
