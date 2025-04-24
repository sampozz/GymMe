import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_service.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../firestore_test.mocks.dart';

void main() {
  provideDummy<Booking>(Booking(id: '1'));

  group('BookingsService', () {
    MockFirebaseFirestore mockFirestore = MockFirebaseFirestore();
    MockFirebaseAuth mockFirebaseAuth = MockFirebaseAuth();
    MockUser mockUser = MockUser();
    MockCollectionReference<Map<String, dynamic>> mockCollectionReference =
        MockCollectionReference<Map<String, dynamic>>();
    MockQuery<Map<String, dynamic>> mockQuery =
        MockQuery<Map<String, dynamic>>();
    MockQuery<Booking> mockQueryBooking = MockQuery<Booking>();
    MockQuerySnapshot<Booking> mockQuerySnapshot = MockQuerySnapshot<Booking>();
    MockQueryDocumentSnapshot<Booking> mockQueryDocumentSnapshot =
        MockQueryDocumentSnapshot<Booking>();

    test('fetchBookings returns a list of bookings', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(
        mockCollectionReference.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.withConverter(
          fromFirestore: anyNamed('fromFirestore'),
          toFirestore: anyNamed('toFirestore'),
        ),
      ).thenReturn(mockQueryBooking);
      when(mockQueryBooking.get()).thenAnswer((_) async => mockQuerySnapshot);

      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);
      when(mockQueryDocumentSnapshot.data()).thenReturn(Booking(id: '1'));

      BookingsService bookingsService = BookingsService(
        firestore: mockFirestore,
        firebaseAuth: mockFirebaseAuth,
      );
      var bookings = await bookingsService.fetchBookings();
      expect(bookings, isA<List<Booking>>());
    });

    test('fetchBookings handles error', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(
        mockCollectionReference.where(any, isEqualTo: anyNamed('isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        mockQuery.withConverter(
          fromFirestore: anyNamed('fromFirestore'),
          toFirestore: anyNamed('toFirestore'),
        ),
      ).thenReturn(mockQueryBooking);
      when(mockQueryBooking.get()).thenThrow(Exception('Error'));

      BookingsService bookingsService = BookingsService(
        firestore: mockFirestore,
        firebaseAuth: mockFirebaseAuth,
      );

      expect(
        () async => await bookingsService.fetchBookings(),
        throwsA(isA<Exception>()),
      );
    });

    test('deleteBooking deletes a booking and updates the slot', () async {
      Booking booking = Booking(id: '1', userId: 'user1', slotId: 'slot1');
      Slot slot = Slot(id: 'slot1');

      final mockTransaction = MockTransaction();
      when(mockFirestore.runTransaction(any)).thenAnswer((invocation) async {
        final transactionFunction =
            invocation.positionalArguments[0]
                as Future<void> Function(MockTransaction transaction);
        await transactionFunction(mockTransaction);
      });

      final bookingRef = MockDocumentReference<Map<String, dynamic>>();
      when(
        mockFirestore.collection('booking'),
      ).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(booking.id)).thenReturn(bookingRef);
      when(mockTransaction.delete(bookingRef)).thenReturn(mockTransaction);

      final slotCol = MockCollectionReference<Map<String, dynamic>>();
      when(mockFirestore.collection('slot')).thenReturn(slotCol);
      final slotRef = MockDocumentReference<Map<String, dynamic>>();
      when(slotCol.doc(slot.id)).thenReturn(slotRef);
      final slotDoc = MockDocumentSnapshot<Map<String, dynamic>>();
      when(slotDoc.exists).thenReturn(true);

      when(mockTransaction.get(slotRef)).thenAnswer((_) async => slotDoc);
      when(mockTransaction.get(bookingRef)).thenAnswer((_) async => slotDoc);

      when(
        mockTransaction.update(slotRef, {
          'bookedUsers': FieldValue.arrayRemove([booking.userId]),
        }),
      ).thenReturn(mockTransaction);

      BookingsService bookingsService = BookingsService(
        firestore: mockFirestore,
        firebaseAuth: mockFirebaseAuth,
      );
      await bookingsService.deleteBooking(booking);
    });

    test('deleteBooking handles error', () async {
      Booking booking = Booking(id: '1', userId: 'user1', slotId: 'slot1');

      when(mockFirestore.runTransaction(any)).thenThrow(Exception('Error'));
      BookingsService bookingsService = BookingsService(
        firestore: mockFirestore,
        firebaseAuth: mockFirebaseAuth,
      );

      expect(
        () async => await bookingsService.deleteBooking(booking),
        throwsA(isA<Exception>()),
      );
    });
  });
}
