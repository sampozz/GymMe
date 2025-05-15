import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late SlotService slotService;
  late Slot testSlot;
  late String slotId;

  setUp(() async {
    // Initialize FakeFirebaseFirestore
    fakeFirestore = FakeFirebaseFirestore();

    // Initialize your service with the fake Firestore
    slotService = SlotService(firestore: fakeFirestore);

    // Create test data
    slotId = 'test-slot-id';
    testSlot = Slot(
      id: slotId,
      startTime: DateTime(2025, 5, 12, 10, 0), // 10:00 AM
      endTime: DateTime(2025, 5, 12, 11, 0), // 11:00 AM
      room: 'Room A',
      // Add any other required fields for your Slot model
    );

    // Create the initial slot in Firestore
    await fakeFirestore
        .collection('slot')
        .doc(slotId)
        .set(testSlot.toFirestore());

    // Create some bookings that reference this slot
    await fakeFirestore.collection('booking').doc('booking1').set({
      'slotId': slotId,
      'startTime': DateTime(2025, 5, 12, 10, 0),
      'endTime': DateTime(2025, 5, 12, 11, 0),
      'room': 'Room A',
      'userId': 'user1',
    });

    await fakeFirestore.collection('booking').doc('booking2').set({
      'slotId': slotId,
      'startTime': DateTime(2025, 5, 12, 10, 0),
      'endTime': DateTime(2025, 5, 12, 11, 0),
      'room': 'Room A',
      'userId': 'user2',
    });
  });

  group('updateSlot', () {
    test('updates slot and all associated bookings', () async {
      // Prepare updated slot data
      final updatedSlot = Slot(
        id: slotId,
        startTime: DateTime(2025, 5, 12, 11, 0), // Changed to 11:00 AM
        endTime: DateTime(2025, 5, 12, 12, 0), // Changed to 12:00 PM
        room: 'Room B', // Changed room
        // Add any other required fields for your Slot model
      );

      // Call the method being tested
      await slotService.updateSlot(updatedSlot);

      // Verify slot was updated
      final updatedSlotDoc =
          await fakeFirestore.collection('slot').doc(slotId).get();
      expect(updatedSlotDoc.exists, true);

      final slotData = updatedSlotDoc.data() as Map<String, dynamic>;
      expect(slotData['room'], 'Room B');
      expect(
        (slotData['startTime'] as Timestamp).toDate(),
        DateTime(2025, 5, 12, 11, 0),
      );
      expect(
        (slotData['endTime'] as Timestamp).toDate(),
        DateTime(2025, 5, 12, 12, 0),
      );

      // Verify all bookings were updated
      final bookingsSnapshot =
          await fakeFirestore
              .collection('booking')
              .where('slotId', isEqualTo: slotId)
              .get();
      expect(bookingsSnapshot.docs.length, 2);

      for (var bookingDoc in bookingsSnapshot.docs) {
        final bookingData = bookingDoc.data();
        expect(bookingData['room'], 'Room B');
        expect(
          (bookingData['startTime'] as Timestamp).toDate(),
          DateTime(2025, 5, 12, 11, 0),
        );
        expect(
          (bookingData['endTime'] as Timestamp).toDate(),
          DateTime(2025, 5, 12, 12, 0),
        );

        // Verify the booking update was added
        expect(bookingData['bookingUpdate'], isNotNull);
        expect(
          bookingData['bookingUpdate']['message'],
          'Your booking has been updated',
        );
        expect(bookingData['bookingUpdate']['read'], false);
        expect(bookingData['bookingUpdate']['updatedAt'], isA<Timestamp>());
      }
    });

    test('throws exception when slot does not exist', () async {
      // Create a slot with non-existent ID
      final nonExistentSlot = Slot(
        id: 'non-existent-id',
        startTime: DateTime(2025, 5, 12, 10, 0),
        endTime: DateTime(2025, 5, 12, 11, 0),
        room: 'Room X',
        // Add any other required fields for your Slot model
      );

      // Expect an exception when trying to update non-existent slot
      expect(
        () => slotService.updateSlot(nonExistentSlot),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Slot does not exist'),
          ),
        ),
      );
    });

    test('updates slot with no associated bookings', () async {
      // Create a new slot without bookings
      final slotWithoutBookingsId = 'slot-without-bookings';
      final slotWithoutBookings = Slot(
        id: slotWithoutBookingsId,
        startTime: DateTime(2025, 5, 12, 14, 0),
        endTime: DateTime(2025, 5, 12, 15, 0),
        room: 'Room C',
        // Add any other required fields for your Slot model
      );

      await fakeFirestore
          .collection('slot')
          .doc(slotWithoutBookingsId)
          .set(slotWithoutBookings.toFirestore());

      // Updated slot data
      final updatedSlot = Slot(
        id: slotWithoutBookingsId,
        startTime: DateTime(2025, 5, 12, 15, 0),
        endTime: DateTime(2025, 5, 12, 16, 0),
        room: 'Room D',
        // Add any other required fields for your Slot model
      );

      // Update the slot
      await slotService.updateSlot(updatedSlot);

      // Verify slot was updated
      final updatedSlotDoc =
          await fakeFirestore
              .collection('slot')
              .doc(slotWithoutBookingsId)
              .get();
      expect(updatedSlotDoc.exists, true);

      final slotData = updatedSlotDoc.data() as Map<String, dynamic>;
      expect(slotData['room'], 'Room D');
      expect(
        (slotData['startTime'] as Timestamp).toDate(),
        DateTime(2025, 5, 12, 15, 0),
      );
      expect(
        (slotData['endTime'] as Timestamp).toDate(),
        DateTime(2025, 5, 12, 16, 0),
      );
    });

    test('fetchUpcomingSlots returns correct slots', () async {
      // Test data
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final dayAfterTomorrow = DateTime(now.year, now.month, now.day + 2);

      final testGymId = 'gym123';
      final testActivityId = 'yoga101';

      // Add some test data to fake Firestore
      await fakeFirestore.collection('slot').add({
        'gymId': testGymId,
        'activityId': testActivityId,
        'startTime': Timestamp.fromDate(tomorrow),
        'endTime': Timestamp.fromDate(tomorrow.add(Duration(hours: 1))),
        'capacity': 20,
        'bookedCount': 5,
      });

      await fakeFirestore.collection('slot').add({
        'gymId': testGymId,
        'activityId': testActivityId,
        'startTime': Timestamp.fromDate(dayAfterTomorrow),
        'endTime': Timestamp.fromDate(dayAfterTomorrow.add(Duration(hours: 1))),
        'capacity': 15,
        'bookedCount': 0,
      });

      // Execute the method under test
      final result = await slotService.fetchUpcomingSlots(
        testGymId,
        testActivityId,
        now,
      );

      // Assertions
      expect(
        result.length,
        2,
      ); // Only the two matching slots should be returned

      // Verify first slot
      expect(result[0].gymId, testGymId);
      expect(result[0].activityId, testActivityId);

      // Verify second slot
      expect(result[1].gymId, testGymId);
      expect(result[1].activityId, testActivityId);
    });

    test('fetchUpcomingSlots returns empty list when no slots match', () async {
      // Test with criteria that doesn't match any records
      final now = DateTime.now();
      final result = await slotService.fetchUpcomingSlots(
        'nonExistentGym',
        'nonExistentActivity',
        now,
      );

      expect(result, isEmpty);
    });

    test('fetchUpcomingSlots correctly filters by date', () async {
      final now = DateTime.now();
      final testDate = DateTime(
        now.year,
        now.month,
        now.day,
        12,
        0,
      ); // Today at noon
      final beforeTestDate = DateTime(
        now.year,
        now.month,
        now.day,
        10,
        0,
      ); // Today at 10am
      final afterTestDate = DateTime(
        now.year,
        now.month,
        now.day,
        14,
        0,
      ); // Today at 2pm

      final testGymId = 'gym123';
      final testActivityId = 'yoga101';

      // Add a slot before the test date (shouldn't be returned)
      await fakeFirestore.collection('slot').add({
        'gymId': testGymId,
        'activityId': testActivityId,
        'startTime': Timestamp.fromDate(beforeTestDate),
        'endTime': Timestamp.fromDate(beforeTestDate.add(Duration(hours: 1))),
        'capacity': 20,
        'bookedCount': 5,
      });

      // Add a slot after the test date (should be returned)
      await fakeFirestore.collection('slot').add({
        'gymId': testGymId,
        'activityId': testActivityId,
        'startTime': Timestamp.fromDate(afterTestDate),
        'endTime': Timestamp.fromDate(afterTestDate.add(Duration(hours: 1))),
        'capacity': 15,
        'bookedCount': 0,
      });

      // Execute with our test date
      final result = await slotService.fetchUpcomingSlots(
        testGymId,
        testActivityId,
        testDate,
      );

      // Assertions
      expect(result.length, 1); // Only slots after testDate should be returned
      expect(result[0].startTime, afterTestDate);
    });
  });

  test('successfully creates a new slot in Firestore', () async {
    // Create a new slot with necessary fields
    final newSlot = Slot(
      id: '', // ID will be assigned by Firestore
      startTime: DateTime(2025, 6, 15, 9, 0), // 9:00 AM
      endTime: DateTime(2025, 6, 15, 10, 0), // 10:00 AM
      room: 'Test Room',
      gymId: 'test-gym',
      activityId: 'test-activity',
    );

    // Call the method being tested
    await slotService.createSlot(newSlot);

    // Query Firestore to verify the slot was created
    final querySnapshot =
        await fakeFirestore
            .collection('slot')
            .where('room', isEqualTo: 'Test Room')
            .get();

    // Verify a document was created
    expect(querySnapshot.docs.length, 1);

    // Get the created slot data
    final createdSlotData = querySnapshot.docs.first.data();

    // Verify the slot data matches what we provided
    expect(createdSlotData['startTime'], isA<Timestamp>());
    expect(
      (createdSlotData['startTime'] as Timestamp).toDate(),
      DateTime(2025, 6, 15, 9, 0),
    );
    expect(
      (createdSlotData['endTime'] as Timestamp).toDate(),
      DateTime(2025, 6, 15, 10, 0),
    );
    expect(createdSlotData['room'], 'Test Room');
    expect(createdSlotData['gymId'], 'test-gym');
    expect(createdSlotData['activityId'], 'test-activity');
  });

  test('deleteSlot deletes a slot and its bookings', () async {
    // Create a new slot to delete
    final newSlot = Slot(
      id: 'slot-to-delete',
      startTime: DateTime(2025, 6, 15, 9, 0),
      endTime: DateTime(2025, 6, 15, 10, 0),
      room: 'Room to Delete',
      gymId: 'test-gym',
      activityId: 'test-activity',
    );

    await fakeFirestore
        .collection('slot')
        .doc(newSlot.id)
        .set(newSlot.toFirestore());

    // Call the delete method
    await slotService.deleteSlot(newSlot.id);

    // Verify the slot was deleted
    final deletedSlotDoc =
        await fakeFirestore.collection('slot').doc(newSlot.id).get();
    expect(deletedSlotDoc.exists, false);

    // Verify associated bookings were deleted
    final bookingsSnapshot =
        await fakeFirestore
            .collection('booking')
            .where('slotId', isEqualTo: newSlot.id)
            .get();
    expect(bookingsSnapshot.docs.length, 0);
  });
}
