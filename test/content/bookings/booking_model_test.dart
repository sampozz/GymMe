import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/booking_update_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../firestore_test.mocks.dart';

void main() {
  group('Booking Model Tests', () {
    test('Booking model should be created correctly', () {
      final booking = Booking(
        id: '123',
        userId: 'user123',
        slotId: 'slot123',
        bookingUpdate: BookingUpdate(bookingId: '123', message: 'Confirmed'),
      );

      expect(booking.id, '123');
      expect(booking.userId, 'user123');
      expect(booking.slotId, 'slot123');
      expect(booking.bookingUpdate?.message, 'Confirmed');
    });

    test('Booking fromFirestore should create a Booking object', () {
      final bookingData = {
        'id': '123',
        'userId': 'user123',
        'slotId': 'slot123',
        'bookingUpdate': {'bookingId': '123', 'message': 'Confirmed'},
      };

      MockDocumentSnapshot<Map<String, dynamic>> bookingSnapshot =
          MockDocumentSnapshot<Map<String, dynamic>>();
      when(bookingSnapshot.data()).thenReturn(bookingData);
      when(bookingSnapshot.id).thenReturn('123');
      when(bookingSnapshot.exists).thenReturn(true);
      final booking = Booking.fromFirestore(bookingSnapshot, null);

      expect(booking.id, '123');
      expect(booking.userId, 'user123');
      expect(booking.slotId, 'slot123');
    });

    test('Booking toFirestore should return a Map', () {
      final booking = Booking(
        id: '123',
        userId: 'user123',
        slotId: 'slot123',
        bookingUpdate: BookingUpdate(bookingId: '123', message: 'Confirmed'),
      );

      final bookingMap = booking.toFirestore();
      expect(bookingMap['userId'], 'user123');
      expect(bookingMap['slotId'], 'slot123');
      expect(bookingMap['bookingUpdate']['bookingId'], '123');
      expect(bookingMap['bookingUpdate']['message'], 'Confirmed');
    });
  });
}
