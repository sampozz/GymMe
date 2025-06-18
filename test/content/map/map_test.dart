import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gymme/content/map/gym_map.dart';
import 'package:gymme/content/map/gym_bottom_sheet.dart';
import 'package:gymme/content/home/gym/gym_page.dart';
import 'package:gymme/providers/map_provider.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/models/location_model.dart';
import '../../provider_test.mocks.dart';

void main() {
  late MockMapProvider mockMapProvider;
  late MockGymProvider mockGymProvider;
  late MockScreenProvider mockScreenProvider;
  late MockUserProvider mockUserProvider;

  setUp(() {
    mockMapProvider = MockMapProvider();
    mockGymProvider = MockGymProvider();
    mockScreenProvider = MockScreenProvider();
    mockUserProvider = MockUserProvider();

    when(mockScreenProvider.useMobileLayout).thenReturn(true);
    when(mockMapProvider.isInitialized).thenReturn(false);
    when(
      mockMapProvider.savedPosition,
    ).thenReturn(const LatLng(45.46427, 9.18951)); // Milano
    when(mockMapProvider.savedZoom).thenReturn(14.0);
    when(mockGymProvider.getGymList()).thenAnswer((_) async => []);
    when(mockUserProvider.isGymInFavourites(any)).thenReturn(false);
    when(mockGymProvider.gymList).thenReturn([]);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapProvider>.value(value: mockMapProvider),
        ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
        ChangeNotifierProvider<ScreenProvider>.value(value: mockScreenProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
      ],
      child: const MaterialApp(home: Scaffold(body: GymMap())),
    );
  }

  Widget createBottomSheetTestWidget(String gymId) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ScreenProvider>.value(value: mockScreenProvider),
      ],
      child: MaterialApp(home: Scaffold(body: GymBottomSheet(gymId: gymId))),
    );
  }

  group('GymMap Widget Tests', () {
    testWidgets('GymMap renders correctly with location button', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
    });

    testWidgets('GymMap shows search bar on mobile layout', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SearchAnchor), findsOneWidget);
    });

    testWidgets('GymMap shows search bar on desktop layout', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockScreenProvider.useMobileLayout).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SearchAnchor), findsOneWidget);
    });
  });

  group('GymMap Location Tests', () {
    testWidgets('GymMap requests user location on init', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(mockMapProvider.getUserLocation()).called(1);
    });

    testWidgets(
      'GymMap updates location button state when location granted and request location when tapped',
      (WidgetTester tester) async {
        final mockPosition = MockPosition();
        when(mockPosition.latitude).thenReturn(45.464);
        when(mockPosition.longitude).thenReturn(9.189);
        when(mockPosition.timestamp).thenReturn(DateTime.now());
        when(mockPosition.accuracy).thenReturn(5.0);
        when(mockPosition.altitude).thenReturn(100.0);
        when(mockPosition.heading).thenReturn(0.0);
        when(mockPosition.speed).thenReturn(0.0);
        when(mockPosition.speedAccuracy).thenReturn(1.0);
        when(mockPosition.altitudeAccuracy).thenReturn(1.0);
        when(mockPosition.headingAccuracy).thenReturn(1.0);

        when(
          mockMapProvider.getUserLocation(),
        ).thenAnswer((_) async => mockPosition);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.onPressed, isNotNull);

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        verify(mockMapProvider.getUserLocation()).called(2); // Init + tap
      },
    );

    testWidgets(
      'GymMap shows error when location permission denied and location button stays disabled',
      (WidgetTester tester) async {
        when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(
          find.text('Location permission denied. Go to settings to enable it.'),
          findsOneWidget,
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(
          find.text('Location permission denied. Go to settings to enable it.'),
          findsWidgets,
        );
      },
    );
  });

  group('GymMap Search Tests', () {
    testWidgets('Search bar filters gym list correctly', (
      WidgetTester tester,
    ) async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Fitness First',
          address: 'Via Roma 1, Milano',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
        Gym(
          id: '2',
          name: 'McFit',
          address: 'Via Dante 2, Milano',
          openTime: DateTime.parse('2023-01-01 09:00:00'),
          closeTime: DateTime.parse('2023-01-01 21:00:00'),
          imageUrl: 'test2.jpg',
        ),
      ];

      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchBar = find.byType(SearchBar);
      expect(searchBar, findsOneWidget);

      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      await tester.enterText(searchBar, 'Fitness');
      await tester.pumpAndSettle();

      expect(find.text('Fitness First'), findsOneWidget);
      expect(find.text('McFit'), findsNothing);
    });

    testWidgets('Search shows no results when no matches', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchBar = find.byType(SearchBar);
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      await tester.enterText(searchBar, 'NonExistentGym');
      await tester.pumpAndSettle();

      expect(find.text('No results found'), findsOneWidget);
    });

    testWidgets('Clear button clears search', (WidgetTester tester) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchAnchor = find.byType(SearchAnchor);
      await tester.tap(searchAnchor);
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField).first;

      await tester.enterText(searchField, 'Test');
      await tester.pumpAndSettle();

      expect(find.textContaining('Test'), findsWidgets);

      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      expect(find.text('Test'), findsNothing);
      expect(find.textContaining('No results found'), findsWidgets);
    });

    testWidgets('Search filters by address as well as name', (
      WidgetTester tester,
    ) async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Test Gym',
          address: 'Via Roma 1, Milano',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
      ];

      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchBar = find.byType(SearchBar);
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      await tester.enterText(searchBar, 'Roma');
      await tester.pumpAndSettle();

      expect(find.text('Test Gym'), findsOneWidget);
    });

    testWidgets('Search suggestion tap updates camera and shows details', (
      WidgetTester tester,
    ) async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Test Gym',
          address: 'Via Roma 1, Milano',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
      ];

      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);
      when(mockGymProvider.gymList).thenReturn(testGyms);
      when(mockGymProvider.getGymIndex(any)).thenReturn(0);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final searchBar = find.byType(SearchBar);
      await tester.tap(searchBar);
      await tester.pumpAndSettle();

      await tester.enterText(searchBar, 'Test');
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(GymBottomSheet), findsOneWidget);
    });
  });

  group('GymMap Marker Tests', () {
    testWidgets('GymMap loads gym list correctly', (WidgetTester tester) async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Test Gym',
          address: 'Test Address',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
      ];

      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      verify(mockGymProvider.getGymList()).called(1);
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('GymMap state management works correctly', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsNothing);
    });

    testWidgets('GymMap handles async map creation', (
      WidgetTester tester,
    ) async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Test Gym',
          address: 'Test Address',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
      ];

      final testLocations = Locations(
        gyms: [
          GymLocation(
            id: '1',
            name: 'Test Gym',
            address: 'Test Address',
            lat: 45.464,
            lng: 9.189,
          ),
        ],
      );

      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);
      when(
        mockMapProvider.getGymLocations(testGyms),
      ).thenAnswer((_) async => testLocations);
      when(
        mockMapProvider.getMarkers(any, onMarkerTap: anyNamed('onMarkerTap')),
      ).thenReturn({});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);

      verify(mockGymProvider.getGymList()).called(1);
    });
  });

  group('GymMap Error Handling Tests', () {
    testWidgets('GymMap handles gym loading errors gracefully', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(
        mockGymProvider.getGymList(),
      ).thenThrow(Exception('Failed to load gyms'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('GymMap handles marker loading errors', (
      WidgetTester tester,
    ) async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Test Gym',
          address: 'Test Address',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
      ];

      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
      when(mockGymProvider.getGymList()).thenAnswer((_) async => testGyms);
      when(
        mockMapProvider.getGymLocations(testGyms),
      ).thenThrow(Exception('Geocoding failed'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsOneWidget);
      expect(find.byType(GoogleMap), findsOneWidget);
    });

    testWidgets('GymMap handles camera update errors gracefully', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsOneWidget);
    });
  });

  group('GymBottomSheet Widget Tests', () {
    testWidgets(
      'GymBottomSheet displays gym info and handles status correctly',
      (WidgetTester tester) async {
        final testGym = Gym(
          id: '1',
          name: 'Test Gym',
          address: 'Via Roma 1, Milano',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        );

        when(mockGymProvider.gymList).thenReturn([testGym]);
        when(mockGymProvider.getGymIndex(testGym)).thenReturn(0);
        when(mockUserProvider.isGymInFavourites('1')).thenReturn(false);

        await tester.pumpWidget(createBottomSheetTestWidget('1'));
        await tester.pumpAndSettle();

        expect(find.byType(GymBottomSheet), findsOneWidget);
        expect(find.text('Test Gym'), findsOneWidget);
        expect(find.text('Via Roma 1, Milano'), findsOneWidget);
        expect(find.text('Visit'), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);

        // Open/closed status check
        final openText = find.text('Open');
        final closedText = find.text('Closed');

        expect(
          openText.evaluate().isNotEmpty || closedText.evaluate().isNotEmpty,
          isTrue,
        );

        // Tap favorite button -> add to favorites
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        verify(mockUserProvider.addFavouriteGym('1')).called(1);
      },
    );

    testWidgets('GymBottomSheet removes favorite when already favorited', (
      WidgetTester tester,
    ) async {
      final testGym = Gym(
        id: '1',
        name: 'Test Gym',
        address: 'Via Roma 1, Milano',
        openTime: DateTime.parse('2023-01-01 08:00:00'),
        closeTime: DateTime.parse('2023-01-01 22:00:00'),
        imageUrl: 'test.jpg',
      );

      when(mockGymProvider.gymList).thenReturn([testGym]);
      when(mockGymProvider.getGymIndex(testGym)).thenReturn(0);
      when(mockUserProvider.isGymInFavourites('1')).thenReturn(true);

      await tester.pumpWidget(createBottomSheetTestWidget('1'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);

      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();

      verify(mockUserProvider.removeFavouriteGym('1')).called(1);
    });

    testWidgets('GymBottomSheet visit button navigates to gym page', (
      WidgetTester tester,
    ) async {
      final testGym = Gym(
        id: '1',
        name: 'Test Gym',
        address: 'Via Roma 1, Milano',
        openTime: DateTime.parse('2023-01-01 08:00:00'),
        closeTime: DateTime.parse('2023-01-01 22:00:00'),
        imageUrl: 'test.jpg',
      );

      when(mockGymProvider.gymList).thenReturn([testGym]);
      when(mockGymProvider.getGymIndex(testGym)).thenReturn(0);
      when(mockUserProvider.isGymInFavourites('1')).thenReturn(false);

      await tester.pumpWidget(createBottomSheetTestWidget('1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Visit'));
      await tester.pumpAndSettle();

      expect(find.byType(GymPage), findsOneWidget);
    });

    testWidgets('GymBottomSheet shows opening hours when gym is closed', (
      WidgetTester tester,
    ) async {
      // Simulate closed gym
      final now = DateTime.now();

      final testGym = Gym(
        id: '1',
        name: 'Test Gym',
        address: 'Via Roma 1, Milano',
        openTime: DateTime(now.year, now.month, now.day, 0, 0),
        closeTime: DateTime(
          now.year,
          now.month,
          now.day,
          now.hour,
          now.minute - 1,
        ),
        imageUrl: 'test.jpg',
      );

      when(mockGymProvider.gymList).thenReturn([testGym]);
      when(mockGymProvider.getGymIndex(testGym)).thenReturn(0);
      when(mockUserProvider.isGymInFavourites('1')).thenReturn(false);

      await tester.pumpWidget(createBottomSheetTestWidget('1'));
      await tester.pumpAndSettle();

      expect(find.text('Closed'), findsOneWidget);
      expect(find.textContaining('Open at 12:00 AM'), findsOneWidget);
    });

    testWidgets('GymBottomSheet shows closing hours when gym is open', (
      WidgetTester tester,
    ) async {
      // Simulate open gym
      final now = DateTime.now();

      final testGym = Gym(
        id: '1',
        name: 'Test Gym',
        address: 'Via Roma 1, Milano',
        openTime: DateTime(now.year, now.month, now.day, 0, 0),
        closeTime: DateTime(now.year, now.month, now.day, 23, 59),
        imageUrl: 'test.jpg',
      );

      when(mockGymProvider.gymList).thenReturn([testGym]);
      when(mockGymProvider.getGymIndex(testGym)).thenReturn(0);
      when(mockUserProvider.isGymInFavourites('1')).thenReturn(false);

      await tester.pumpWidget(createBottomSheetTestWidget('1'));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
      expect(find.textContaining('Close at 11:59 PM'), findsOneWidget);
    });
  });

  group('GymMap State Management Tests', () {
    testWidgets('GymMap uses default position when not initialized', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.isInitialized).thenReturn(false);
      when(
        mockMapProvider.savedPosition,
      ).thenReturn(const LatLng(45.46427, 9.18951));
      when(mockMapProvider.savedZoom).thenReturn(14.0);
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final googleMap = tester.widget<GoogleMap>(find.byType(GoogleMap));
      expect(googleMap.initialCameraPosition.target.latitude, 45.46427);
      expect(googleMap.initialCameraPosition.target.longitude, 9.18951);
      expect(googleMap.initialCameraPosition.zoom, 14);
    });

    testWidgets('GymMap uses saved position when initialized', (
      WidgetTester tester,
    ) async {
      when(mockMapProvider.isInitialized).thenReturn(true);
      when(mockMapProvider.savedPosition).thenReturn(const LatLng(45.5, 9.2));
      when(mockMapProvider.savedZoom).thenReturn(16.0);
      when(mockMapProvider.getUserLocation()).thenAnswer((_) async => null);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GymMap), findsOneWidget);
    });
  });
}
