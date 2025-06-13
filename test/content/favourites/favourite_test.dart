import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/content/favourites/favourites.dart';
import 'package:gymme/content/home/gym/gym_card.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/content/home/gym/gym_page.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:gymme/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  group('Favourites', () {
    testWidgets('should show a list of GymCards', (WidgetTester tester) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final bookingsProvider = MockBookingsProvider();

      // Create a mock list of gyms
      final gymList = [
        Gym(id: '1', name: 'Gym 1', imageUrl: 'url1'),
        Gym(id: '2', name: 'Gym 2', imageUrl: 'url2'),
      ];

      // Set up the mock providers to return the gym list and favourite gyms IDs
      when(gymProvider.gymList).thenReturn(gymList);
      when(userProvider.user).thenReturn(User(favouriteGyms: ['1']));

      // Build the Favourites widget with the mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
          ],
          child: MaterialApp(home: Scaffold(body: Favourites())),
        ),
      );

      // Verify that the GymCards are displayed correctly
      expect(find.text('Your favourite gyms'), findsOneWidget);
      expect(find.byType(GymCard), findsNWidgets(1));
    });

    testWidgets('tap on GymCard should navigate to gym page', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final bookingsProvider = MockBookingsProvider();
      final screenProvider = MockScreenProvider();

      // Create a mock list of gyms
      final gymList = [
        Gym(id: '1', name: 'Gym 1'),
        Gym(id: '2', name: 'Gym 2'),
      ];

      // Set up the mock providers to return the gym list and favourite gyms IDs
      when(gymProvider.gymList).thenReturn(gymList);
      when(userProvider.user).thenReturn(User(favouriteGyms: ['1']));
      when(screenProvider.useMobileLayout).thenReturn(false);

      // Build the Favourites widget with the mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(value: screenProvider),
          ],
          child: MaterialApp(home: Scaffold(body: Favourites())),
        ),
      );

      // Tap on the GymCard and trigger a frame
      await tester.tap(find.byType(GymCard).first);
      await tester.pumpAndSettle();

      // Verify that the navigation to the GymPage occurred
      expect(find.byType(GymPage), findsOneWidget);
    });

    testWidgets('should refresh gyms when pull to refresh is used', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final bookingsProvider = MockBookingsProvider();

      // Create a mock list of gyms
      final gymList = [
        Gym(id: '1', name: 'Gym 1'),
        Gym(id: '2', name: 'Gym 2'),
      ];

      // Set up the mock providers to return the gym list and favourite gyms IDs
      when(gymProvider.gymList).thenReturn(gymList);
      when(userProvider.user).thenReturn(User(favouriteGyms: ['1']));

      // Build the Favourites widget with the mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
          ],
          child: MaterialApp(home: Scaffold(body: Favourites())),
        ),
      );

      // Pull to refresh and trigger a frame
      final listViewFinder = find.byType(ListView);
      await tester.drag(listViewFinder, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Verify that the refresh method was called on the User and Gym providers
      verify(userProvider.fetchUser()).called(1);
      verify(gymProvider.getGymList()).called(1);
      await tester.pumpAndSettle();
    });

    testWidgets('should show a ProgressIndicator if gymList is null', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final bookingsProvider = MockBookingsProvider();

      // Set up the mock providers to return null for gymList
      when(gymProvider.gymList).thenReturn(null);
      when(userProvider.user).thenReturn(User(favouriteGyms: ['1']));

      // Build the Favourites widget with the mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
          ],
          child: MaterialApp(home: Scaffold(body: Favourites())),
        ),
      );

      // Verify that a CircularProgressIndicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should indicate if no favourite gyms are available', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final bookingsProvider = MockBookingsProvider();

      // Create a mock list of gyms
      final gymList = [
        Gym(id: '1', name: 'Gym 1'),
        Gym(id: '2', name: 'Gym 2'),
      ];

      // Set up the mock providers to return the gym list and empty favourite gyms IDs
      when(gymProvider.gymList).thenReturn(gymList);
      when(userProvider.user).thenReturn(User(favouriteGyms: []));

      // Build the Favourites widget with the mock providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: bookingsProvider,
            ),
          ],
          child: MaterialApp(home: Scaffold(body: Favourites())),
        ),
      );

      // Verify that a message indicating no favourite gyms is displayed
      expect(find.text('No favourite gyms yet'), findsOneWidget);
    });
  });
}
