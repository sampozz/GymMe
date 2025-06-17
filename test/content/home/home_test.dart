import 'package:gymme/models/booking_model.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/content/bookings/booking_card.dart';
import 'package:gymme/content/home/gym/gym_card.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/content/home/gym/gym_page.dart';
import 'package:gymme/content/home/gym/new_gym.dart';
import 'package:gymme/content/home/home.dart';
import 'package:gymme/content/home/home_loading.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/providers/map_provider.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/theme_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  MockUserProvider mockUserProvider = MockUserProvider();
  MockGymProvider mockGymProvider = MockGymProvider();
  MockBookingsProvider mockBookingsProvider = MockBookingsProvider();
  MockScreenProvider mockScreenProvider = MockScreenProvider();

  setUp(() {
    // Add any necessary setup code here
  });

  group('Home', () {
    testWidgets('Mobile Home shows a loading shimmer', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a loading state
      when(mockUserProvider.user).thenReturn(null);
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(
              value: MockThemeProvider(),
            ),
            ChangeNotifierProvider<MapProvider>.value(value: MockMapProvider()),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(home: Home()),
        ),
      );

      // Verify that the loading shimmer is displayed
      expect(find.byType(HomeLoading), findsOneWidget);
    });

    testWidgets('Desktop Home shows a loading shimmer', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a loading state
      when(mockUserProvider.user).thenReturn(null);
      when(mockScreenProvider.useMobileLayout).thenReturn(false);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ThemeProvider>.value(
              value: MockThemeProvider(),
            ),
            ChangeNotifierProvider<MapProvider>.value(value: MockMapProvider()),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(home: Home()),
        ),
      );

      // Verify that the loading shimmer is displayed
      expect(find.byType(HomeLoading), findsOneWidget);
    });

    testWidgets('Mobile Home shows a list of gyms', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a user
      when(mockUserProvider.user).thenReturn(User(uid: '1'));
      when(mockScreenProvider.useMobileLayout).thenReturn(true);
      when(mockGymProvider.gymList).thenReturn([Gym(id: '1', name: 'Gym 1')]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(home: Home()),
        ),
      );

      // Verify that the list of gyms is displayed
      expect(find.byType(GymCard), findsOneWidget);
    });

    testWidgets('Desktop Home shows a list of gyms', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a user
      when(mockUserProvider.user).thenReturn(User(uid: '1'));
      when(mockScreenProvider.useMobileLayout).thenReturn(false);
      when(mockGymProvider.gymList).thenReturn([Gym(id: '1', name: 'Gym 1')]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MapProvider>.value(value: MockMapProvider()),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(home: Home()),
        ),
      );

      // Verify that the list of gyms is displayed
      expect(find.byType(GymCard), findsOneWidget);
    });

    testWidgets('Refresh indicator calls getGymList on GymProvider', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a user
      when(mockUserProvider.user).thenReturn(User(uid: '1'));
      when(mockScreenProvider.useMobileLayout).thenReturn(true);
      when(mockGymProvider.gymList).thenReturn([Gym(id: '1', name: 'Gym 1')]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(home: Home()),
        ),
      );

      // Expect a gym card to be present
      expect(find.byType(GymCard), findsOneWidget);
      clearInteractions(mockGymProvider);

      final sliverListFinder = find.byType(GymCard);
      expect(sliverListFinder, findsOneWidget);

      // Perform pull to refresh action on the ListView
      await tester.drag(sliverListFinder, const Offset(0, 300));
      await tester.pump();

      // Wait for the refresh indicator animation
      await tester.pump(const Duration(seconds: 1));

      // Verify that getGymList was called
      verify(mockGymProvider.getGymList()).called(1);
    });

    testWidgets('Navigate to gym page on tap on gym card', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a user with favorites
      when(mockUserProvider.user).thenReturn(User(uid: '1', favouriteGyms: []));
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      // Mock gym-related methods and properties to prevent async loading
      final mockGym = Gym(id: '1', name: 'Gym 1');
      when(mockGymProvider.gymList).thenReturn([mockGym]);
      when(mockGymProvider.getGymIndex(mockGym)).thenReturn(0);
      when(mockGymProvider.getGymList()).thenAnswer((_) => Future.value([]));

      // Mock bookings to prevent async loading
      when(
        mockBookingsProvider.getTodaysBookings(),
      ).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MapProvider>.value(value: MockMapProvider()),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              // This suppresses animations in the test
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: Home(),
          ),
        ),
      );

      // Allow initial futures to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verify that the list of gyms is displayed
      expect(find.byType(GymCard), findsOneWidget);

      // Tap on the gym card
      await tester.tap(find.byType(GymCard));

      // Process the tap and initial navigation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that the navigation occurred
      expect(find.byType(GymPage), findsOneWidget);
    });

    testWidgets('Desktop Navigate to gym page on tap on gym card', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a user with favorites
      when(mockUserProvider.user).thenReturn(User(uid: '1', favouriteGyms: []));
      when(mockScreenProvider.useMobileLayout).thenReturn(false);

      // Mock gym-related methods and properties to prevent async loading
      final mockGym = Gym(id: '1', name: 'Gym 1');
      when(mockGymProvider.gymList).thenReturn([mockGym]);
      when(mockGymProvider.getGymIndex(mockGym)).thenReturn(0);
      when(mockGymProvider.getGymList()).thenAnswer((_) => Future.value([]));

      // Mock bookings to prevent async loading
      when(
        mockBookingsProvider.getTodaysBookings(),
      ).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<MapProvider>.value(value: MockMapProvider()),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              // This suppresses animations in the test
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: Home(),
          ),
        ),
      );

      // Allow initial futures to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verify that the list of gyms is displayed
      expect(find.byType(GymCard), findsOneWidget);

      // Tap on the gym card
      await tester.tap(find.byType(GymCard));

      // Process the tap and initial navigation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that the navigation occurred
      expect(find.byType(GymPage), findsOneWidget);
    });

    testWidgets('Shows todays bookings when available', (
      WidgetTester tester,
    ) async {
      // Create mock bookings for today
      final mockBooking = Booking(
        id: 'booking1',
        userId: '1',
        gymId: '1',
        activityId: 'activity1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
      );

      // Mock the providers
      when(mockUserProvider.user).thenReturn(User(uid: '1', favouriteGyms: []));
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      // Create mock gym
      final mockGym = Gym(id: '1', name: 'Gym 1');
      when(mockGymProvider.gymList).thenReturn([mockGym]);
      when(mockGymProvider.getGymIndex(mockGym)).thenReturn(0);
      when(
        mockGymProvider.getGymList(),
      ).thenAnswer((_) => Future.value([mockGym]));

      // Mock bookings provider to return our mock booking
      when(
        mockBookingsProvider.getTodaysBookings(),
      ).thenAnswer((_) => Future.value([mockBooking]));
      when(mockBookingsProvider.getBookingIndex(mockBooking.id)).thenReturn(0);
      when(mockBookingsProvider.bookings).thenReturn([mockBooking]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              // This suppresses animations
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: Home(),
          ),
        ),
      );

      // Allow widget to build and futures to resolve
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Verify that "Upcoming bookings" text is shown
      expect(find.text('Upcoming bookings'), findsOneWidget);

      // Verify that the BookingCard widget is displayed
      expect(find.byType(BookingCard), findsOneWidget);
    });

    testWidgets('Shows new Gym page when tap on new gym button', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider to return a user with favorites
      when(
        mockUserProvider.user,
      ).thenReturn(User(uid: '1', isAdmin: true, favouriteGyms: []));
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      // Mock gym-related methods and properties to prevent async loading
      final mockGym = Gym(id: '1', name: 'Gym 1');
      when(mockGymProvider.gymList).thenReturn([mockGym]);
      when(mockGymProvider.getGymIndex(mockGym)).thenReturn(0);
      when(mockGymProvider.getGymList()).thenAnswer((_) => Future.value([]));

      // Mock bookings to prevent async loading
      when(
        mockBookingsProvider.getTodaysBookings(),
      ).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              // This suppresses animations in the test
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: Home(),
          ),
        ),
      );

      // Allow initial futures to complete
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Tap on the button
      await tester.tap(find.text('Add a new gym'));

      // Process the tap and initial navigation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify that the navigation occurred
      expect(find.byType(NewGym), findsOneWidget);
    });

    testWidgets('Clear icon in search bar clears text when tapped', (
      WidgetTester tester,
    ) async {
      // Mock the providers
      when(mockUserProvider.user).thenReturn(User(uid: '1', favouriteGyms: []));
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      // Create mock gyms
      final mockGym1 = Gym(id: '1', name: 'Fitness Center');
      final mockGym2 = Gym(id: '2', name: 'Yoga Studio');
      final gymList = [mockGym1, mockGym2];

      // Mock gym provider
      when(mockGymProvider.gymList).thenReturn(gymList);
      when(
        mockGymProvider.getGymList(),
      ).thenAnswer((_) => Future.value(gymList));
      when(mockGymProvider.getGymIndex(mockGym1)).thenReturn(0);
      when(mockGymProvider.getGymIndex(mockGym2)).thenReturn(1);

      // Mock bookings provider to return empty bookings to avoid additional complexity
      when(
        mockBookingsProvider.getTodaysBookings(),
      ).thenAnswer((_) => Future.value([]));

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<BookingsProvider>.value(
              value: mockBookingsProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(
              value: mockScreenProvider,
            ),
          ],
          child: MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              );
            },
            home: Home(),
          ),
        ),
      );

      // Allow widget to build and futures to resolve
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Find the search field
      final searchField = find.byType(SearchBar);
      expect(searchField, findsOneWidget);

      // Tap on the search field to focus it
      await tester.tap(searchField);
      await tester.pump();

      // Enter search text
      await tester.enterText(searchField, 'Yoga');
      await tester.pump();

      // Verify that clear icon is shown
      final clearIcon = find.byIcon(Icons.clear);
      expect(clearIcon, findsOneWidget);

      // Tap the clear icon
      await tester.tap(clearIcon);
      await tester.pump();

      // Verify that search text is cleared
      // We need to find the actual TextFormField to check its value
      expect(tester.widget<SearchBar>(searchField).controller!.text, isEmpty);
    });
  });
}
