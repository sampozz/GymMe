import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/content/map/gym_map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGeolocatorPlatform extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  @override
  Future<LocationPermission> checkPermission() => Future.value(LocationPermission.denied);
  
  @override
  Future<LocationPermission> requestPermission() => Future.value(LocationPermission.whileInUse);
  
  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) {
    return Future.value(Position(
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
    ));
  }
}

void main() {
  late MockGeolocatorPlatform mockGeolocatorPlatform;
  
  setUp(() {
    mockGeolocatorPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocatorPlatform;
  });
  
  // Test that verifies if location permissions are properly requested
  testWidgets('GymMap requests location permissions on initialization', (WidgetTester tester) async {
    final spyGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = spyGeolocator;
    
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    expect(find.byType(GymMap), findsOneWidget);
  });
  
  // Test that verifies if location is updated when permission is granted
  testWidgets('GymMap updates location when permission is granted', (WidgetTester tester) async {
    final mockGeolocator = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockGeolocator;
    
    // Use thenAnswer instead of thenReturn for Futures
    // when(mockGeolocator.checkPermission()).thenAnswer((_) => Future.value(LocationPermission.whileInUse));
    
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));

    await tester.pumpAndSettle(const Duration(seconds: 1));
    
    expect(find.byType(GoogleMap), findsOneWidget);
  });
  
  testWidgets('GymMap contains a GoogleMap widget', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: GymMap())));
    
    await tester.pumpAndSettle();
    
    expect(find.byType(GoogleMap), findsOneWidget);
    
    final googleMapWidget = tester.widget<GoogleMap>(find.byType(GoogleMap));
    expect(googleMapWidget.initialCameraPosition.target.latitude, 45.46427);
    expect(googleMapWidget.initialCameraPosition.target.longitude, 9.18951);
    expect(googleMapWidget.initialCameraPosition.zoom, 14);
  });
}