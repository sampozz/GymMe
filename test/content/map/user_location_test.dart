import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/content/map/gym_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:dima_project/global_providers/map_provider.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';

// Mocks
class MockMapProvider extends Mock implements MapProvider {}
class MockGymProvider extends Mock implements GymProvider {}

void main() {
  late MockMapProvider mockMapProvider;
  late MockGymProvider mockGymProvider;
  
  setUp(() {
    mockMapProvider = MockMapProvider();
    mockGymProvider = MockGymProvider();
    
    when(() => mockGymProvider.getGymList()).thenAnswer((_) async => <Gym>[]);
    
    // Configure mock responses for MapProvider
    when(() => mockMapProvider.getUserLocation()).thenAnswer((_) async => 
      Position(
        latitude: 45.46427,
        longitude: 9.18951,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 1.0,
        heading: 1.0,
        speed: 1.0,
        speedAccuracy: 1.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      )
    );
  });
  
  // Helper function to build the widget with providers
  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MapProvider>.value(value: mockMapProvider),
        ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
      ],
      child: const MaterialApp(
        home: Scaffold(body: GymMap()),
      ),
    );
  }
  
  // Test that verifies if location permissions are properly requested
  testWidgets('GymMap requests location permissions on initialization', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    
    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    expect(find.byType(GymMap), findsOneWidget);
    
    // Verify that the MapProvider's getUserLocation was called
    verify(() => mockMapProvider.getUserLocation()).called(1);
  });
  
  // Test that verifies if location is updated when permission is granted
  testWidgets('GymMap updates location when permission is granted', (WidgetTester tester) async {
    // Setup test
    when(() => mockMapProvider.getUserLocation()).thenAnswer((_) async => 
      Position(
        latitude: 45.55, // Different position than default
        longitude: 9.25,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 1.0,
        heading: 1.0,
        speed: 1.0,
        speedAccuracy: 1.0,
        altitudeAccuracy: 1.0,
        headingAccuracy: 1.0,
      )
    );
    
    await tester.pumpWidget(createTestWidget());
    
    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    // Verify that map exists
    expect(find.byType(GoogleMap), findsOneWidget);
    
    // Verify that MapProvider was called
    verify(() => mockMapProvider.getUserLocation()).called(1);
  });
  
  testWidgets('GymMap contains a GoogleMap widget with correct initial position', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    
    await tester.pumpAndSettle();
    
    expect(find.byType(GoogleMap), findsOneWidget);
    
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(googleMapWidget.initialCameraPosition.target.latitude, 45.46427);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 9.18951);
    expect(googleMapWidget.initialCameraPosition.zoom, 14);
  });
  
  // Test when location permission is denied
  testWidgets('GymMap handles denied location permission correctly', (WidgetTester tester) async {
    // Setup for denied permission scenario
    when(() => mockMapProvider.getUserLocation()).thenAnswer((_) async => null);
    
    await tester.pumpWidget(createTestWidget());
    
    await tester.pumpAndSettle();
    
    // Verify that map exists with default position
    expect(find.byType(GoogleMap), findsOneWidget);
    
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(googleMapWidget.initialCameraPosition.target.latitude, 45.46427);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 9.18951);
    
    // Verify that MapProvider was called
    verify(() => mockMapProvider.getUserLocation()).called(1);
  });
}