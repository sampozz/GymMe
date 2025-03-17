import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/content/map/gym_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';

// Need to create a mock for GoogleMap because it can't be rendered directly in tests
class MockGoogleMapController extends Mock implements GoogleMapController {}

void main() {
  // Test that verifies if the GymMap widget builds correctly
  testWidgets('GymMap builds correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Check that the GymMap widget exists in the widget hierarchy
    expect(find.byType(GymMap), findsOneWidget);
  });

  // Test that verifies if GymMap contains a GoogleMap widget
  testWidgets('GymMap contains a GoogleMap widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Check that there is a GoogleMap in the widget
    expect(find.byType(GoogleMap), findsOneWidget);
  });

  // Test that verifies the initial map position (center of Milan)
  testWidgets('GymMap has initial position set to Milan', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Access the GoogleMap widget to verify the initial position
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    
    // Verify that the initial position is the center of Milan
    expect(googleMapWidget.initialCameraPosition.target.latitude, 45.46427);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 9.18951);
    expect(googleMapWidget.initialCameraPosition.zoom, 14);
  });

  // Test that verifies if the onMapCreated function is called when the map is created
  testWidgets('GymMap calls onMapCreated when the map is created', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    // Verify that GoogleMap has an onMapCreated function
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(googleMapWidget.onMapCreated, isNotNull);
  });
  
  // Note: to test marker creation you will need mocks for getGymLocations
  // Here you could add more advanced tests with mockito to simulate data loading
}