import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/bookings_service.dart';
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
    BookingsService bookingsService = BookingsService(
      firestore: mockFirestore,
      firebaseAuth: mockFirebaseAuth,
    );

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

      var bookings = await bookingsService.fetchBookings();
      expect(bookings, isA<List<Booking>>());
    });
  });
}
