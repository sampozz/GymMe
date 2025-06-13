import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/models/location_model.dart';
import 'package:gymme/providers/map_provider.dart';
import '../provider_test.mocks.dart';
import '../service_test.mocks.dart';

void main() {
  late MapProvider mapProvider;
  late MockMapService mockMapService;

  setUp(() {
    mockMapService = MockMapService();
    mapProvider = MapProvider(mapService: mockMapService);
  });

  group('MapProvider Initialization Tests', () {
    test('MapProvider initializes with default values', () {
      expect(mapProvider.isInitialized, false);
      expect(mapProvider.savedPosition, const LatLng(45.46427, 9.18951));
      expect(mapProvider.savedZoom, 14.0);
    });

    test('saveMapState stores position and zoom correctly', () {
      const testPosition = LatLng(45.464, 9.189);
      const testZoom = 15.0;

      mapProvider.saveMapState(testPosition, testZoom);

      expect(mapProvider.savedPosition, testPosition);
      expect(mapProvider.savedZoom, testZoom);
    });
  });

  group('MapProvider Location Tests', () {
    test('getUserLocation returns Position when service succeeds', () async {
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
        mockMapService.fetchUserLocation(),
      ).thenAnswer((_) async => mockPosition);

      final result = await mapProvider.getUserLocation();

      expect(result, isNotNull);
      expect(result!.latitude, 45.464);
      expect(result.longitude, 9.189);
      verify(mockMapService.fetchUserLocation()).called(1);
    });

    test('getUserLocation returns null when service fails', () async {
      when(mockMapService.fetchUserLocation()).thenAnswer((_) async => null);

      final result = await mapProvider.getUserLocation();

      expect(result, isNull);
      verify(mockMapService.fetchUserLocation()).called(1);
    });

    test('getUserLocation throws exception when service throws', () async {
      when(
        mockMapService.fetchUserLocation(),
      ).thenThrow(Exception('Location service error'));

      expect(() => mapProvider.getUserLocation(), throwsA(isA<Exception>()));

      verify(mockMapService.fetchUserLocation()).called(1);
    });
  });

  group('MapProvider Gym Location Tests', () {
    test('getGymLocations processes gyms correctly', () async {
      final testGyms = [
        Gym(
          id: '1',
          name: 'Test Gym 1',
          address: 'Via Roma 1, Milano',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'test.jpg',
        ),
      ];

      final expectedLocations = Locations(
        gyms: [
          GymLocation(
            id: '1',
            name: 'Test Gym 1',
            address: 'Via Roma 1, Milano',
            lat: 45.464,
            lng: 9.189,
          ),
        ],
      );

      when(
        mockMapService.fetchGymLocations(testGyms),
      ).thenAnswer((_) async => expectedLocations);

      final result = await mapProvider.getGymLocations(testGyms);

      expect(result, expectedLocations);
      verify(mockMapService.fetchGymLocations(testGyms)).called(1);
    });

    test('getGymLocations handles empty gym list', () async {
      when(
        mockMapService.fetchGymLocations([]),
      ).thenAnswer((_) async => Locations(gyms: []));

      final result = await mapProvider.getGymLocations([]);

      expect(result.gyms, isEmpty);
      verify(mockMapService.fetchGymLocations([])).called(1);
    });

    test('getGymLocations throws exception when service throws', () async {
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

      when(
        mockMapService.fetchGymLocations(testGyms),
      ).thenThrow(Exception('Geocoding error'));

      expect(
        () => mapProvider.getGymLocations(testGyms),
        throwsA(isA<Exception>()),
      );
      verify(mockMapService.fetchGymLocations(testGyms)).called(1);
    });
  });

  group('MapProvider Marker Tests', () {
    test('getMarkers creates correct markers from locations', () {
      final testLocations = Locations(
        gyms: [
          GymLocation(
            id: '1',
            name: 'Test Gym 1',
            address: 'Via Roma 1, Milano',
            lat: 45.464,
            lng: 9.189,
          ),
          GymLocation(
            id: '2',
            name: 'Test Gym 2',
            address: 'Via Dante 2, Milano',
            lat: 45.465,
            lng: 9.190,
          ),
        ],
      );

      var tappedGymId = '';
      var tappedGymName = '';

      final markers = mapProvider.getMarkers(
        testLocations,
        onMarkerTap: (gymName, gymId) {
          tappedGymName = gymName;
          tappedGymId = gymId;
        },
      );

      expect(markers, isA<Map<String, Marker>>());
      expect(markers.length, 2);
      expect(markers.containsKey('1'), true);
      expect(markers.containsKey('2'), true);

      // Test marker properties
      final marker1 = markers['1']!;
      expect(marker1.markerId.value, '1');
      expect(marker1.position.latitude, 45.464);
      expect(marker1.position.longitude, 9.189);

      // Test marker tap
      marker1.onTap!();
      expect(tappedGymId, '1');
      expect(tappedGymName, 'Test Gym 1');
    });

    test('getMarkers handles empty location list', () {
      final emptyLocations = Locations(gyms: []);

      final markers = mapProvider.getMarkers(
        emptyLocations,
        onMarkerTap: (gymName, gymId) {},
      );

      expect(markers, isEmpty);
    });

    test('getMarkers handles null callback', () {
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

      expect(
        () => mapProvider.getMarkers(testLocations, onMarkerTap: null),
        returnsNormally,
      );
    });

    test('getMarkers handles invalid coordinates gracefully', () {
      final testLocations = Locations(
        gyms: [
          GymLocation(
            id: '1',
            name: 'Invalid Coordinates Gym',
            address: 'Invalid Address',
            lat: 0.0, // Default coordinates
            lng: 0.0,
          ),
        ],
      );

      final markers = mapProvider.getMarkers(
        testLocations,
        onMarkerTap: (gymName, gymId) {},
      );

      expect(markers.length, 1);
      final marker = markers['1']!;
      expect(marker.position.latitude, 0.0);
      expect(marker.position.longitude, 0.0);
    });
  });

  group('MapProvider State Management Tests', () {
    test('saveMapState stores position and zoom correctly', () {
      const testPosition = LatLng(45.464, 9.189);
      const testZoom = 15.0;

      mapProvider.saveMapState(testPosition, testZoom);

      expect(mapProvider.savedPosition, testPosition);
      expect(mapProvider.savedZoom, testZoom);
    });

    test('notifyListeners is called by getUserLocation', () async {
      var notifyCount = 0;
      mapProvider.addListener(() => notifyCount++);

      when(mockMapService.fetchUserLocation()).thenAnswer((_) async => null);

      await mapProvider.getUserLocation();

      expect(notifyCount, 1);
    });

    test('notifyListeners is called by getGymLocations', () async {
      var notifyCount = 0;
      mapProvider.addListener(() => notifyCount++);

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

      when(
        mockMapService.fetchGymLocations(testGyms),
      ).thenAnswer((_) async => Locations(gyms: []));

      await mapProvider.getGymLocations(testGyms);

      expect(notifyCount, 1);
    });

    test('notifyListeners is called by getMarkers', () {
      var notifyCount = 0;
      mapProvider.addListener(() => notifyCount++);

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

      mapProvider.getMarkers(testLocations);

      expect(notifyCount, 1);
    });

    test('notifyListeners is called by setInitialized', () {
      var notifyCount = 0;
      mapProvider.addListener(() => notifyCount++);

      mapProvider.setInitialized(true);

      expect(notifyCount, 1);
    });

    test('multiple state saves update correctly', () {
      const position1 = LatLng(45.464, 9.189);
      const position2 = LatLng(45.465, 9.190);
      const zoom1 = 15.0;
      const zoom2 = 16.0;

      mapProvider.saveMapState(position1, zoom1);
      expect(mapProvider.savedPosition, position1);
      expect(mapProvider.savedZoom, zoom1);

      mapProvider.saveMapState(position2, zoom2);
      expect(mapProvider.savedPosition, position2);
      expect(mapProvider.savedZoom, zoom2);
    });

    test('multiple listeners are notified correctly', () async {
      var listener1Count = 0;
      var listener2Count = 0;

      mapProvider.addListener(() => listener1Count++);
      mapProvider.addListener(() => listener2Count++);

      when(mockMapService.fetchUserLocation()).thenAnswer((_) async => null);

      await mapProvider.getUserLocation();

      expect(listener1Count, 1);
      expect(listener2Count, 1);

      mapProvider.setInitialized(false);

      expect(listener1Count, 2);
      expect(listener2Count, 2);
    });

    test('isInitialized is updated correctly by getMarkers', () {
      expect(mapProvider.isInitialized, false);

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

      mapProvider.getMarkers(testLocations);

      expect(mapProvider.isInitialized, true);
    });

    test('isInitialized can be set explicitly', () {
      expect(mapProvider.isInitialized, false);

      mapProvider.setInitialized(true);
      expect(mapProvider.isInitialized, true);

      mapProvider.setInitialized(false);
      expect(mapProvider.isInitialized, false);
    });
  });

  group('MapProvider Edge Cases', () {
    test(
      'provider handles service methods that return null consistently',
      () async {
        when(mockMapService.fetchUserLocation()).thenAnswer((_) async => null);
        when(
          mockMapService.fetchGymLocations(any),
        ).thenAnswer((_) async => Locations(gyms: []));

        final userLocation = await mapProvider.getUserLocation();
        final gymLocations = await mapProvider.getGymLocations([]);

        expect(userLocation, isNull);
        expect(gymLocations.gyms, isEmpty);
      },
    );

    test('getMarkers clears previous markers', () {
      // First set of markers
      final firstLocations = Locations(
        gyms: [
          GymLocation(
            id: '1',
            name: 'Gym 1',
            address: 'Address 1',
            lat: 45.464,
            lng: 9.189,
          ),
        ],
      );

      final firstMarkers = mapProvider.getMarkers(firstLocations);
      expect(firstMarkers.length, 1);

      // Second set of markers
      final secondLocations = Locations(
        gyms: [
          GymLocation(
            id: '2',
            name: 'Gym 2',
            address: 'Address 2',
            lat: 45.465,
            lng: 9.190,
          ),
          GymLocation(
            id: '3',
            name: 'Gym 3',
            address: 'Address 3',
            lat: 45.466,
            lng: 9.191,
          ),
        ],
      );

      final secondMarkers = mapProvider.getMarkers(secondLocations);
      expect(secondMarkers.length, 2);
      expect(secondMarkers.containsKey('1'), false); // Previous markers cleared
      expect(secondMarkers.containsKey('2'), true);
      expect(secondMarkers.containsKey('3'), true);
    });

    test('savedPosition and savedZoom have correct default values', () {
      // Before any state is saved
      expect(mapProvider.savedPosition.latitude, 45.46427);
      expect(mapProvider.savedPosition.longitude, 9.18951);
      expect(mapProvider.savedZoom, 14.0);
    });

    test('setInitialized works correctly', () {
      expect(mapProvider.isInitialized, false);

      mapProvider.setInitialized(true);
      expect(mapProvider.isInitialized, true);

      mapProvider.setInitialized(false);
      expect(mapProvider.isInitialized, false);
    });
  });
}
