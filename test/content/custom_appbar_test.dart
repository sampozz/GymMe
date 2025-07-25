import 'package:gymme/models/booking_model.dart';
import 'package:gymme/models/booking_update_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/content/custom_appbar.dart';
import 'package:gymme/content/notifications/notifications.dart';
import 'package:gymme/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../provider_test.mocks.dart';

void main() {
  group('CustomAppBar', () {
    testWidgets('should show notification badge if notifications', (
      WidgetTester tester,
    ) async {
      final user = User(uid: '1');
      final bookings = [
        Booking(
          id: '1',
          userId: '1',
          bookingUpdate: BookingUpdate(read: false),
        ),
      ];

      final bookingsProvider = MockBookingsProvider();
      when(bookingsProvider.bookings).thenReturn(bookings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
          ],
          child: MaterialApp(home: CustomAppBar(user: user)),
        ),
      );

      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('tap on notifications button navigates to notifications', (
      WidgetTester tester,
    ) async {
      final user = User(uid: '1');
      final bookings = [
        Booking(
          id: '1',
          userId: '1',
          bookingUpdate: BookingUpdate(read: false),
        ),
      ];

      final bookingsProvider = MockBookingsProvider();
      when(bookingsProvider.bookings).thenReturn(bookings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
          ],
          child: MaterialApp(home: CustomAppBar(user: user)),
        ),
      );

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(Notifications), findsOneWidget);
    });
  });
}
