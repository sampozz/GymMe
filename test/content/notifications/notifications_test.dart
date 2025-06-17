import 'package:gymme/models/booking_model.dart';
import 'package:gymme/models/booking_update_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/content/bookings/booking_page.dart';
import 'package:gymme/content/notifications/notifications.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  group('Notifications', () {
    testWidgets('should display the notifications screen', (
      WidgetTester tester,
    ) async {
      // Mock the necessary providers and data
      final mockBookingsProvider = MockBookingsProvider();
      when(mockBookingsProvider.getBookingUpdates()).thenAnswer(
        (_) async => [
          BookingUpdate(bookingId: '1', updatedAt: DateTime.now(), read: false),
        ],
      );
      when(mockBookingsProvider.markUpdateAsRead(any)).thenAnswer((_) async {});
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookingsProvider>.value(
          value: mockBookingsProvider,
          child: MaterialApp(home: Notifications()),
        ),
      );

      expect(find.byType(Notifications), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('tap should navigate to booking page', (
      WidgetTester tester,
    ) async {
      // Mock the necessary providers and data
      final mockScreenProvider = MockScreenProvider();
      final mockBookingsProvider = MockBookingsProvider();
      final bookingUpdate = BookingUpdate(
        bookingId: '1',
        updatedAt: DateTime.now(),
        read: false,
      );

      when(
        mockBookingsProvider.bookings,
      ).thenReturn([Booking(id: '1', bookingUpdate: bookingUpdate)]);
      when(
        mockBookingsProvider.getBookingUpdates(),
      ).thenAnswer((_) async => [bookingUpdate]);
      when(mockBookingsProvider.markUpdateAsRead(any)).thenAnswer((_) async {});
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(home: Notifications()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('should mark notification as read', (
      WidgetTester tester,
    ) async {
      // Mock the necessary providers and data
      final mockBookingsProvider = MockBookingsProvider();
      final bookingUpdate = BookingUpdate(
        bookingId: '1',
        updatedAt: DateTime.now(),
        read: false,
      );

      when(
        mockBookingsProvider.getBookingUpdates(),
      ).thenAnswer((_) async => [bookingUpdate]);
      when(mockBookingsProvider.markUpdateAsRead(any)).thenAnswer((_) async {});
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);

      await tester.pumpWidget(
        ChangeNotifierProvider<BookingsProvider>.value(
          value: mockBookingsProvider,
          child: MaterialApp(home: Notifications()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.circle_outlined));
      await tester.pumpAndSettle();

      expect(bookingUpdate.read, isTrue);
    });
  });
}
