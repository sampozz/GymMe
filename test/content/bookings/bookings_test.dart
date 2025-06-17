import 'package:gymme/models/booking_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/content/bookings/booking_card.dart';
import 'package:gymme/content/bookings/booking_page.dart';
import 'package:gymme/content/bookings/bookings.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  group('Bookings', () {
    MockBookingsProvider mockBookingsProvider = MockBookingsProvider();

    testWidgets('should show a list of bookings', (WidgetTester tester) async {
      List<Booking> bookings = [
        Booking(id: '1', startTime: DateTime.now().add(Duration(days: 1))),
        Booking(id: '2', startTime: DateTime.now().add(Duration(days: 2))),
      ];

      when(mockBookingsProvider.bookings).thenReturn(bookings);
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);
      when(
        mockBookingsProvider.getBookings(),
      ).thenAnswer((_) async => bookings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScreenProvider()),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
          ],
          child: MaterialApp(home: Bookings()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsExactly(2));
    });

    testWidgets('tap on BookingCard should navigate to booking page', (
      WidgetTester tester,
    ) async {
      Booking booking = Booking(
        id: '1',
        startTime: DateTime.now().add(Duration(days: 1)),
      );

      when(mockBookingsProvider.bookings).thenReturn([booking]);
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);
      when(
        mockBookingsProvider.getBookings(),
      ).thenAnswer((_) async => [booking]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScreenProvider()),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
          ],
          child: MaterialApp(home: Bookings()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BookingCard), findsOneWidget);

      await tester.tap(find.byType(BookingCard));
      await tester.pumpAndSettle();

      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('booking page desktop shows booking info', (
      WidgetTester tester,
    ) async {
      MockScreenProvider mockScreenProvider = MockScreenProvider();
      when(mockScreenProvider.useMobileLayout).thenReturn(false);

      Booking booking = Booking(
        id: '1',
        startTime: DateTime.now().add(Duration(days: 1)),
      );

      when(mockBookingsProvider.bookings).thenReturn([booking]);
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);
      when(
        mockBookingsProvider.getBookings(),
      ).thenAnswer((_) async => [booking]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
          ],
          child: MaterialApp(home: Bookings()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(BookingCard));

      await tester.pumpAndSettle();

      expect(find.byType(BookingPage), findsOneWidget);
    });

    testWidgets('should display tabs for Upcoming and Past bookings', (
      WidgetTester tester,
    ) async {
      List<Booking> bookings = [
        Booking(id: '1', startTime: DateTime.now().add(Duration(days: 1))),
        Booking(id: '2', startTime: DateTime.now().subtract(Duration(days: 1))),
      ];

      when(mockBookingsProvider.bookings).thenReturn(bookings);
      when(mockBookingsProvider.getBookingIndex(any)).thenAnswer((invocation) {
        final String id = invocation.positionalArguments[0];
        return bookings.indexWhere((booking) => booking.id == id);
      });
      when(
        mockBookingsProvider.getBookings(),
      ).thenAnswer((_) async => bookings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScreenProvider()),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
          ],
          child: MaterialApp(home: Bookings()),
        ),
      );

      await tester.pumpAndSettle();

      // Check if both tabs exist
      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Past'), findsOneWidget);

      // Initially we should be on Upcoming tab with only the future booking
      expect(find.byType(BookingCard), findsOneWidget);

      // Tap on Past tab
      await tester.tap(find.text('Past'));
      await tester.pumpAndSettle();

      // Should show past booking
      expect(find.byType(BookingCard), findsOneWidget);
    });

    testWidgets('should show message when no bookings are available', (
      WidgetTester tester,
    ) async {
      when(mockBookingsProvider.bookings).thenReturn([]);
      when(mockBookingsProvider.getBookings()).thenAnswer((_) async => []);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScreenProvider()),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
          ],
          child: MaterialApp(home: Bookings()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No bookings available'), findsWidgets);
    });

    testWidgets('should refresh bookings when pull to refresh is used', (
      WidgetTester tester,
    ) async {
      List<Booking> bookings = [
        Booking(id: '1', startTime: DateTime.now().add(Duration(days: 1))),
      ];

      when(mockBookingsProvider.bookings).thenReturn(bookings);
      when(mockBookingsProvider.getBookingIndex(any)).thenReturn(0);
      when(
        mockBookingsProvider.getBookings(),
      ).thenAnswer((_) async => bookings);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ScreenProvider()),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
          ],
          child: MaterialApp(home: Bookings()),
        ),
      );

      // First verify that the BookingCard exists
      expect(find.byType(BookingCard), findsWidgets);

      // Reset any calls to getBookings that might have happened during initialization
      clearInteractions(mockBookingsProvider);

      // Find the ListView inside the TabBarView (first tab is active by default)
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      // Perform pull to refresh action on the ListView
      await tester.drag(listViewFinder, const Offset(0, 300));
      await tester.pump();

      // Wait for the refresh indicator animation
      await tester.pump(const Duration(seconds: 1));

      // Verify refresh was called
      verify(mockBookingsProvider.getBookings()).called(1);

      await tester.pumpAndSettle();
    });

    testWidgets('Cancel booking functionality works correctly', (
      WidgetTester tester,
    ) async {
      // Setup mocks
      MockScreenProvider mockScreenProvider = MockScreenProvider();
      Booking booking = Booking(
        id: '1',
        startTime: DateTime.now().add(Duration(days: 1)),
        endTime: DateTime.now().add(Duration(days: 2)),
        title: 'Test Booking',
      );
      List<Booking> bookings = [booking];
      when(mockBookingsProvider.bookings).thenReturn(bookings);
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      // Build the widget
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
          child: const MaterialApp(
            home: Scaffold(body: BookingPage(bookingIndex: 0)),
          ),
        ),
      );

      // Verify the widget loaded correctly
      expect(find.text('Test Booking'), findsOneWidget);

      // Find the cancel button
      final cancelButton = find.text('Cancel Booking');
      expect(cancelButton, findsOneWidget);

      // Scroll to make the button visible
      await tester.ensureVisible(cancelButton);

      // Tap the cancel button
      await tester.tap(cancelButton);

      // Pump a few frames to ensure the modal has time to appear
      await tester.pump(); // Start animation
      await tester.pump(
        const Duration(milliseconds: 300),
      ); // Animation in progress
      await tester.pump(
        const Duration(milliseconds: 300),
      ); // Animation complete

      // Verify the modal appears
      expect(
        find.text('Are you sure you want to cancel this booking?'),
        findsOneWidget,
      );

      // Find and tap the confirm cancel button in the modal
      final cancelButtonInModal = find.text('Confirm Cancellation');
      expect(cancelButtonInModal, findsOneWidget);

      // Tap the button in the modal
      await tester.tap(cancelButtonInModal);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Animation in progress

      // Verify removeBooking was called with the correct booking
      verify(mockBookingsProvider.removeBooking(bookings[0])).called(1);
    });
  });
}
