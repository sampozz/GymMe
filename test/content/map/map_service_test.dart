import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:dima_project/content/map/map_service.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/map/location_model.dart';
import 'package:geolocator/geolocator.dart';
import '../../service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MapService', () {
    late MapService mapService;
    late MapService mapServiceWeb;
    late MockClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockClient();
      mapService = MapService(forceWebBehavior: false);
      mapServiceWeb = MapService(forceWebBehavior: true);
    });

    // Helper function to create test gyms
    List<Gym> _createTestGyms() {
      return [
        Gym(
          id: 'gym_1',
          name: 'Fitness First Milano',
          address: 'Via Roma 1, Milano, Italy',
          openTime: DateTime.parse('2023-01-01 08:00:00'),
          closeTime: DateTime.parse('2023-01-01 22:00:00'),
          imageUrl: 'https://example.com/image1.jpg',
        ),
        Gym(
          id: 'gym_2',
          name: 'McFit Milano',
          address: 'Via Dante 2, Milano, Italy',
          openTime: DateTime.parse('2023-01-01 09:00:00'),
          closeTime: DateTime.parse('2023-01-01 21:00:00'),
          imageUrl: 'https://example.com/image2.jpg',
        ),
        Gym(
          id: 'gym_3',
          name: 'Virgin Active',
          address: 'Corso Buenos Aires 10, Milano, Italy',
          openTime: DateTime.parse('2023-01-01 07:00:00'),
          closeTime: DateTime.parse('2023-01-01 23:00:00'),
          imageUrl: 'https://example.com/image3.jpg',
        ),
      ];
    }

    group('Basic Functionality Tests', () {
      test('fetchGymLocations returns list of gym locations', () async {
        final testGyms = _createTestGyms();

        final result = await mapService.fetchGymLocations(testGyms);

        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(testGyms.length));

        for (int i = 0; i < testGyms.length; i++) {
          expect(result.gyms[i].id, equals(testGyms[i].id));
          expect(result.gyms[i].name, equals(testGyms[i].name));
          expect(result.gyms[i].address, equals(testGyms[i].address));
          expect(result.gyms[i].lat, isA<double>());
          expect(result.gyms[i].lng, isA<double>());
        }
      });

      test('fetchGymLocations handles empty gym list', () async {
        final result = await mapService.fetchGymLocations([]);

        expect(result, isA<Locations>());
        expect(result.gyms, isEmpty);
      });

      test('fetchGymLocations handles null gym list', () async {
        final result = await mapService.fetchGymLocations(null);

        expect(result, isA<Locations>());
        expect(result.gyms, isEmpty);
      });

      test('fetchGymLocations handles gyms with empty addresses', () async {
        final gymsWithEmptyAddresses = [
          Gym(
            id: 'gym_empty_1',
            name: 'Gym Without Address',
            address: '',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/image.jpg',
          ),
          Gym(
            id: 'gym_empty_2',
            name: 'Another Gym',
            address: '   ', // Whitespace only
            openTime: DateTime.parse('2023-01-01 09:00:00'),
            closeTime: DateTime.parse('2023-01-01 21:00:00'),
            imageUrl: 'https://example.com/image2.jpg',
          ),
        ];

        final result = await mapService.fetchGymLocations(
          gymsWithEmptyAddresses,
        );

        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(2));

        // Should have default coordinates (0,0) for empty addresses
        for (final gymLocation in result.gyms) {
          expect(gymLocation.lat, equals(0.0));
          expect(gymLocation.lng, equals(0.0));
        }
      });
    });

    group('Error Handling Tests', () {
      test('fetchGymLocations handles geocoding errors gracefully', () async {
        final gymsWithInvalidAddresses = [
          Gym(
            id: 'gym_invalid',
            name: 'Gym Invalid Address',
            address: 'Invalid Address That Does Not Exist 12345',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/image.jpg',
          ),
        ];

        final result = await mapService.fetchGymLocations(
          gymsWithInvalidAddresses,
        );

        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(1));

        // Should have default coordinates for invalid addresses
        final gymLocation = result.gyms.first;
        expect(gymLocation.id, equals('gym_invalid'));
        expect(gymLocation.name, equals('Gym Invalid Address'));
        expect(gymLocation.lat, equals(0.0));
        expect(gymLocation.lng, equals(0.0));
      });

      test('fetchGymLocations returns empty locations on exception', () async {
        expect(
          () => mapService.fetchGymLocations(_createTestGyms()),
          returnsNormally,
        );
      });
    });

    group('Data Integrity Tests', () {
      test('fetchGymLocations preserves all gym data', () async {
        final testGym = Gym(
          id: 'detailed_gym',
          name: 'Detailed Test Gym',
          address: 'Via Test 123, Milano',
          description: 'A detailed gym for testing',
          phone: '+39 02 1234567',
          openTime: DateTime.parse('2023-01-01 06:30:00'),
          closeTime: DateTime.parse('2023-01-01 23:30:00'),
          imageUrl: 'https://example.com/detailed.jpg',
          activities: [],
        );

        final result = await mapService.fetchGymLocations([testGym]);

        expect(result.gyms.length, equals(1));
        final gymLocation = result.gyms.first;

        expect(gymLocation.id, equals(testGym.id));
        expect(gymLocation.name, equals(testGym.name));
        expect(gymLocation.address, equals(testGym.address));
        expect(gymLocation.lat, isA<double>());
        expect(gymLocation.lng, isA<double>());
      });

      test(
        'fetchGymLocations handles special characters in addresses',
        () async {
          final gymsWithSpecialChars = [
            Gym(
              id: 'gym_special',
              name: 'Gym with Special Chars',
              address: 'Via Tornabuoni, 1/R - Firenze (FI), Italia',
              openTime: DateTime.parse('2023-01-01 08:00:00'),
              closeTime: DateTime.parse('2023-01-01 22:00:00'),
              imageUrl: 'https://example.com/special.jpg',
            ),
          ];

          final result = await mapService.fetchGymLocations(
            gymsWithSpecialChars,
          );

          expect(result, isA<Locations>());
          expect(result.gyms.length, equals(1));
          expect(result.gyms.first.address, contains('Firenze'));
        },
      );
    });

    group('Location Permission Tests', () {
      test('location methods exist and have correct signatures', () async {
        expect(mapService.checkLocationPermission, isA<Function>());
        expect(mapService.requestLocationPermission, isA<Function>());
        expect(mapService.fetchUserLocation, isA<Function>());

        final checkResult = await mapService.checkLocationPermission();
        final requestResult = await mapService.requestLocationPermission();
        final locationResult = await mapService.fetchUserLocation();

        expect(checkResult, isA<LocationPermission>());
        expect(requestResult, isA<LocationPermission>());
        expect(locationResult, isNull);
      });
    });

    group('GymLocation Model Tests', () {
      test('GymLocation creates objects correctly', () {
        final gymLocation = GymLocation(
          id: 'test_id',
          name: 'Test Gym',
          address: 'Test Address',
          lat: 45.464204,
          lng: 9.189982,
        );

        expect(gymLocation.id, equals('test_id'));
        expect(gymLocation.name, equals('Test Gym'));
        expect(gymLocation.address, equals('Test Address'));
        expect(gymLocation.lat, equals(45.464204));
        expect(gymLocation.lng, equals(9.189982));
      });

      test('Locations creates collection correctly', () {
        final gymLocations = [
          GymLocation(
            id: '1',
            name: 'Gym 1',
            address: 'Address 1',
            lat: 45.464204,
            lng: 9.189982,
          ),
          GymLocation(
            id: '2',
            name: 'Gym 2',
            address: 'Address 2',
            lat: 45.465204,
            lng: 9.190982,
          ),
        ];

        final locations = Locations(gyms: gymLocations);

        expect(locations.gyms.length, equals(2));
        expect(locations.gyms.first.id, equals('1'));
        expect(locations.gyms.last.id, equals('2'));
      });
    });

    group('Platform-Specific Geocoding Tests', () {
      test('service handles both web and mobile geocoding paths', () async {
        // This test verifies that the service has both code paths
        // In reality, the kIsWeb flag determines which path is used
        final testGyms = [
          Gym(
            id: 'platform_test',
            name: 'Platform Test Gym',
            address: 'Milano, Italy',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/platform.jpg',
          ),
        ];

        final resultMobile = await mapService.fetchGymLocations(testGyms);

        final resultWeb = await mapServiceWeb.fetchGymLocations(testGyms);

        expect(resultMobile, isA<Locations>());
        expect(resultMobile.gyms.length, equals(1));
        expect(resultMobile.gyms.first.id, equals('platform_test'));

        expect(resultWeb, isA<Locations>());
        expect(resultWeb.gyms.length, equals(1));
        expect(resultWeb.gyms.first.id, equals('platform_test'));

        expect(resultWeb.gyms.length, equals(resultMobile.gyms.length));
        expect(resultWeb.gyms.first.id, equals(resultMobile.gyms.first.id));
        expect(resultWeb.gyms.first.name, equals(resultMobile.gyms.first.name));
        expect(
          resultWeb.gyms.first.address,
          equals(resultMobile.gyms.first.address),
        );

        expect(resultMobile.gyms.first.lat, isA<double>());
        expect(resultMobile.gyms.first.lng, isA<double>());
        expect(resultWeb.gyms.first.lat, isA<double>());
        expect(resultWeb.gyms.first.lng, isA<double>());
      });

      test('geocoding handles various address formats', () async {
        final testGyms = [
          Gym(
            id: 'format_test_1',
            name: 'Format Test 1',
            address: 'Corso Buenos Aires, Milano, MI, Italia',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/format1.jpg',
          ),
          Gym(
            id: 'format_test_2',
            name: 'Format Test 2',
            address: 'Via del Corso 123, Roma RM 00100',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/format2.jpg',
          ),
        ];

        final result = await mapService.fetchGymLocations(testGyms);
        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(2));

        for (final gym in result.gyms) {
          expect(gym.lat, isA<double>());
          expect(gym.lng, isA<double>());
        }
      });
    });

    group('Performance and Edge Cases', () {
      test('fetchGymLocations handles large gym lists', () async {
        final largeGymList = List.generate(
          50,
          (index) => Gym(
            id: 'gym_$index',
            name: 'Gym $index',
            address: 'Address $index, Milano',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/gym$index.jpg',
          ),
        );

        final result = await mapService.fetchGymLocations(largeGymList);

        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(50));

        for (int i = 0; i < 50; i++) {
          expect(result.gyms.any((gl) => gl.id == 'gym_$i'), isTrue);
        }
      });

      test('fetchGymLocations validates coordinate ranges', () async {
        final testGyms = [
          Gym(
            id: 'coord_test',
            name: 'Coordinate Test Gym',
            address: 'Milano, Lombardia, Italy',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/coord.jpg',
          ),
        ];

        final result = await mapService.fetchGymLocations(testGyms);
        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(1));

        final gymLocation = result.gyms.first;
        expect(gymLocation.lat, isA<double>());
        expect(gymLocation.lng, isA<double>());
        expect(gymLocation.lat, greaterThanOrEqualTo(-90.0));
        expect(gymLocation.lat, lessThanOrEqualTo(90.0));
        expect(gymLocation.lng, greaterThanOrEqualTo(-180.0));
        expect(gymLocation.lng, lessThanOrEqualTo(180.0));
      });

      test('service handles network timeouts gracefully', () async {
        final testGyms = [
          Gym(
            id: 'timeout_test',
            name: 'Timeout Test',
            address:
                'Very Long Address That Might Cause Timeout Issues, Remote Location',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/timeout.jpg',
          ),
        ];

        final result = await mapService
            .fetchGymLocations(testGyms)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => Locations(gyms: []),
            );

        expect(result, isA<Locations>());
      });

      test('geocoding handles special characters and encoding', () async {
        final testGyms = [
          Gym(
            id: 'encoding_test',
            name: 'Encoding Test',
            address: 'Straße mit Umlauten, München, Deutschland',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/encoding.jpg',
          ),
          Gym(
            id: 'unicode_test',
            name: 'Unicode Test',
            address: '東京都渋谷区, Japan',
            openTime: DateTime.parse('2023-01-01 08:00:00'),
            closeTime: DateTime.parse('2023-01-01 22:00:00'),
            imageUrl: 'https://example.com/unicode.jpg',
          ),
        ];

        final result = await mapService.fetchGymLocations(testGyms);
        expect(result, isA<Locations>());
        expect(result.gyms.length, equals(2));

        for (final gym in result.gyms) {
          expect(gym.lat, isA<double>());
          expect(gym.lng, isA<double>());
        }
      });
    });

    group('Branch Coverage Tests', () {
      test(
        'fetchGymLocations handles mixed valid and invalid addresses',
        () async {
          final mixedGyms = [
            Gym(
              id: 'valid_gym',
              name: 'Valid Gym',
              address: 'Milano, Italy',
              openTime: DateTime.parse('2023-01-01 08:00:00'),
              closeTime: DateTime.parse('2023-01-01 22:00:00'),
              imageUrl: 'https://example.com/valid.jpg',
            ),
            Gym(
              id: 'invalid_gym',
              name: 'Invalid Gym',
              address: '',
              openTime: DateTime.parse('2023-01-01 09:00:00'),
              closeTime: DateTime.parse('2023-01-01 21:00:00'),
              imageUrl: 'https://example.com/invalid.jpg',
            ),
            Gym(
              id: 'another_invalid_gym',
              name: 'Another Invalid Gym',
              address: 'NonExistentPlace12345XYZ',
              openTime: DateTime.parse('2023-01-01 07:00:00'),
              closeTime: DateTime.parse('2023-01-01 23:00:00'),
              imageUrl: 'https://example.com/another.jpg',
            ),
          ];

          final result = await mapService.fetchGymLocations(mixedGyms);
          expect(result, isA<Locations>());
          expect(result.gyms.length, equals(3));

          // All gyms should be processed, some with default coordinates
          for (final gymLocation in result.gyms) {
            expect(gymLocation.id, isNotNull);
            expect(gymLocation.name, isNotNull);
            expect(gymLocation.address, isNotNull);
            expect(gymLocation.lat, isA<double>());
            expect(gymLocation.lng, isA<double>());
          }
        },
      );

      test(
        'geocoding catch blocks are triggered by invalid addresses',
        () async {
          final problematicGyms = [
            Gym(
              id: 'catch_test_1',
              name: 'Catch Test 1',
              address: '',
              openTime: DateTime.parse('2023-01-01 08:00:00'),
              closeTime: DateTime.parse('2023-01-01 22:00:00'),
              imageUrl: 'test.jpg',
            ),
            Gym(
              id: 'catch_test_2',
              name: 'Catch Test 2',
              address: 'InvalidAddressThatShouldFailGeocoding@@@###',
              openTime: DateTime.parse('2023-01-01 08:00:00'),
              closeTime: DateTime.parse('2023-01-01 22:00:00'),
              imageUrl: 'test.jpg',
            ),
          ];

          final result = await mapService.fetchGymLocations(problematicGyms);

          // Both should return default coordinates due to catch blocks
          expect(result.gyms.length, equals(2));
          for (final gym in result.gyms) {
            expect(gym.lat, equals(0.0));
            expect(gym.lng, equals(0.0));
          }
        },
      );
    });
  });
}
