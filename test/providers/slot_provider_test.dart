import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/slot_model.dart';
import 'package:dima_project/providers/slot_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../firestore_test.mocks.dart';
import '../service_test.mocks.dart';

void main() {
  group('SlotProvider tests', () {
    late MockSlotService mockSlotService;

    setUp(() {
      mockSlotService = MockSlotService();
    });

    test('getNextAvailableSlots should return a list of slots', () async {
      MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
      var slotProvider = SlotProvider(
        slotService: mockSlotService,
        gymId: '1',
        activityId: '1',
        firebaseAuth: mockFirebaseAuth,
      );

      var slotList = [
        Slot(startTime: DateTime(10, 10)),
        Slot(startTime: DateTime(11, 10)),
      ];

      when(
        mockSlotService.fetchUpcomingSlots(any, any, any),
      ).thenAnswer((_) async => slotList);

      var res = await slotProvider.getUpcomingSlots();
      expect(res, slotList);
    });

    test('createSlot should call the slot service to create a slot', () async {
      var now = DateTime.now();

      MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
      var slotProvider = SlotProvider(
        slotService: mockSlotService,
        gymId: '1',
        activityId: '1',
        firebaseAuth: mockFirebaseAuth,
      );

      var slot = Slot(
        gymId: '1',
        activityId: '1',
        startTime: now,
        endTime: now.add(Duration(hours: 1)),
        maxUsers: 10,
        room: 'Room A',
        bookedUsers: ['user1', 'user2'],
      );

      await slotProvider.createSlot(slot, 'Daily', now.add(Duration(days: 3)));

      verify(mockSlotService.createSlot(any)).called(4);
    });

    test(
      'createSlot weekly should call the slot service to create a slot',
      () async {
        var now = DateTime.now();

        MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
        var slotProvider = SlotProvider(
          slotService: mockSlotService,
          gymId: '1',
          activityId: '1',
          firebaseAuth: mockFirebaseAuth,
        );

        var slot = Slot(
          gymId: '1',
          activityId: '1',
          startTime: now,
          endTime: now.add(Duration(hours: 1)),
          maxUsers: 10,
          room: 'Room A',
          bookedUsers: ['user1', 'user2'],
        );

        await slotProvider.createSlot(
          slot,
          'Weekly',
          now.add(Duration(days: 14)),
        );

        verify(mockSlotService.createSlot(any)).called(3);
      },
    );

    test(
      'createSlot monthly should call the slot service to create a slot',
      () async {
        var now = DateTime.now();

        MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
        var slotProvider = SlotProvider(
          slotService: mockSlotService,
          gymId: '1',
          activityId: '1',
          firebaseAuth: mockFirebaseAuth,
        );

        var slot = Slot(
          gymId: '1',
          activityId: '1',
          startTime: now,
          endTime: now.add(Duration(hours: 1)),
          maxUsers: 10,
          room: 'Room A',
          bookedUsers: ['user1', 'user2'],
        );

        await slotProvider.createSlot(
          slot,
          'Monthly',
          now.add(Duration(days: 70)),
        );

        verify(mockSlotService.createSlot(any)).called(3);
      },
    );

    test('updateSlot should call the slot service to update a slot', () async {
      var now = DateTime.now();

      MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
      var slotProvider = SlotProvider(
        slotService: mockSlotService,
        gymId: '1',
        activityId: '1',
        firebaseAuth: mockFirebaseAuth,
      );

      var slot = Slot(
        gymId: '1',
        activityId: '1',
        startTime: now,
        endTime: now.add(Duration(hours: 1)),
        maxUsers: 10,
        room: 'Room A',
        bookedUsers: ['user1', 'user2'],
      );

      await slotProvider.updateSlot(slot);

      verify(mockSlotService.updateSlot(any)).called(1);
    });

    test('deleteSlot should call the slot service to delete a slot', () async {
      MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
      var slotProvider = SlotProvider(
        slotService: mockSlotService,
        gymId: '1',
        activityId: '1',
        firebaseAuth: mockFirebaseAuth,
      );

      await slotProvider.deleteSlot('1');

      verify(mockSlotService.deleteSlot(any)).called(1);
    });

    test('addUserToSlot should add a user to the user list', () async {
      MockUser user = MockUser();
      when(user.uid).thenReturn('user1');
      MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
      when(mockFirebaseAuth.currentUser).thenReturn(user);

      when(mockSlotService.fetchUpcomingSlots(any, any, any)).thenAnswer(
        (_) async => [
          Slot(id: '1', bookedUsers: List<String>.of([], growable: true)),
        ],
      );

      var slotProvider = SlotProvider(
        slotService: mockSlotService,
        gymId: '1',
        activityId: '1',
        firebaseAuth: mockFirebaseAuth,
      );

      await slotProvider.getUpcomingSlots();
      await slotProvider.addUserToSlot('1');

      expect(slotProvider.nextSlots![0].bookedUsers, ['user1']);
    });

    test('Slot fromFirestore should create a Slot object', () {
      var data = {
        'gymId': '1',
        'activityId': '1',
        'startTime': Timestamp.fromDate(DateTime(2023, 10, 10)),
        'endTime': Timestamp.fromDate(DateTime(2023, 10, 11)),
        'maxUsers': 10,
        'room': 'Room A',
        'bookedUsers': ['user1', 'user2'],
      };

      var documentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(documentSnapshot.data()).thenReturn(data);

      var slot = Slot.fromFirestore(documentSnapshot, null);

      expect(slot.gymId, '1');
      expect(slot.activityId, '1');
      expect(slot.startTime, DateTime(2023, 10, 10));
      expect(slot.endTime, DateTime(2023, 10, 11));
      expect(slot.maxUsers, 10);
      expect(slot.room, 'Room A');
      expect(slot.bookedUsers, ['user1', 'user2']);
    });

    test('Slot toFirestore should return a map', () {
      var slot = Slot(
        gymId: '1',
        activityId: '1',
        startTime: DateTime(2023, 10, 10),
        endTime: DateTime(2023, 10, 11),
        maxUsers: 10,
        room: 'Room A',
        bookedUsers: ['user1', 'user2'],
      );

      var map = slot.toFirestore();

      expect(map['gymId'], '1');
      expect(map['activityId'], '1');
      expect(map['startTime'], DateTime(2023, 10, 10));
      expect(map['endTime'], DateTime(2023, 10, 11));
      expect(map['maxUsers'], 10);
      expect(map['room'], 'Room A');
      expect(map['bookedUsers'], ['user1', 'user2']);
    });

    test('Slot copyWith should return a new instance with updated values', () {
      var slot = Slot(
        gymId: '1',
        activityId: '1',
        startTime: DateTime(2023, 10, 10),
        endTime: DateTime(2023, 10, 11),
        maxUsers: 10,
        room: 'Room A',
        bookedUsers: ['user1', 'user2'],
      );

      var updatedSlot = slot.copyWith(gymId: '2', activityId: '2');

      expect(updatedSlot.gymId, '2');
      expect(updatedSlot.activityId, '2');
      expect(updatedSlot.startTime, DateTime(2023, 10, 10));
      expect(updatedSlot.endTime, DateTime(2023, 10, 11));
      expect(updatedSlot.maxUsers, 10);
      expect(updatedSlot.room, 'Room A');
      expect(updatedSlot.bookedUsers, ['user1', 'user2']);
    });
  });
}
