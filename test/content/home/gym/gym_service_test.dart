import 'dart:convert';

import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../../service_test.mocks.dart';

void main() {
  group('GymService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late GymService gymService;
    late MockClient mockHttpClient;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockHttpClient = MockClient();
      gymService = GymService(
        firestore: fakeFirestore,
        httpClient: mockHttpClient, // Inject mock HTTP client
      );
    });

    // Helper function to add test gym data
    Future<List<String>> _addTestGyms() async {
      List<String> gymIds = [];

      // Add a few test gyms
      for (int i = 0; i < 3; i++) {
        final gym = Gym(
          id: 'test_id_$i',
          name: 'Test Gym $i',
          description: 'Description $i',
          imageUrl: 'https://example.com/image$i.jpg',
          activities: [
            Activity(
              id: 'activity_id_$i',
              description: 'Activity Description $i',
            ),
          ],
        );

        final docRef = await fakeFirestore
            .collection('gym')
            .add(gym.toFirestore());

        gymIds.add(docRef.id);
      }

      return gymIds;
    }

    test('fetchGymList returns list of gyms', () async {
      // Arrange
      await _addTestGyms();

      // Act
      final gymList = await gymService.fetchGymList();

      // Assert
      expect(gymList, isA<List<Gym>>());
      expect(gymList.length, 3);
      for (int i = 0; i < 3; i++) {
        expect(gymList.any((gym) => gym.name == 'Test Gym $i'), isTrue);
        expect(
          gymList.any((gym) => gym.description == 'Description $i'),
          isTrue,
        );
      }
    });

    test('addGym adds gym to Firestore and returns ID', () async {
      // Arrange
      final gym = Gym(
        name: 'New Test Gym',
        description: 'New Description',
        imageUrl: 'https://example.com/newimage.jpg',
        activities: [],
      );

      // Act
      final gymId = await gymService.addGym(gym);

      // Assert
      expect(gymId, isNotEmpty);

      // Verify gym was added to Firestore
      final docSnapshot =
          await fakeFirestore.collection('gym').doc(gymId).get();
      expect(docSnapshot.exists, isTrue);

      final gymData = docSnapshot.data() as Map<String, dynamic>;
      expect(gymData['name'], 'New Test Gym');
      expect(gymData['description'], 'New Description');
    });

    test('updateGym updates existing gym', () async {
      // Arrange
      final gymIds = await _addTestGyms();
      final gymId = gymIds[0];

      final updatedGym = Gym(
        id: gymId,
        name: 'Updated Gym',
        description: 'Updated Description',
        imageUrl: 'https://example.com/updated.jpg',
        activities: [],
      );

      // Act
      await gymService.updateGym(updatedGym);

      // Assert
      final docSnapshot =
          await fakeFirestore.collection('gym').doc(gymId).get();
      final gymData = docSnapshot.data() as Map<String, dynamic>;

      expect(gymData['name'], 'Updated Gym');
      expect(gymData['description'], 'Updated Description');
      expect(gymData['imageUrl'], 'https://example.com/updated.jpg');
    });

    test('deleteGym removes gym from Firestore', () async {
      // Arrange
      final gymIds = await _addTestGyms();
      final gymIdToDelete = gymIds[0];

      // Verify gym exists before deletion
      final beforeSnapshot =
          await fakeFirestore.collection('gym').doc(gymIdToDelete).get();
      expect(beforeSnapshot.exists, isTrue);

      // Act
      await gymService.deleteGym(gymIdToDelete);

      // Assert
      final afterSnapshot =
          await fakeFirestore.collection('gym').doc(gymIdToDelete).get();
      expect(afterSnapshot.exists, isFalse);
    });

    test('setActivity updates activities in a gym', () async {
      // Arrange
      final gymIds = await _addTestGyms();
      final gymId = gymIds[0];

      // Get the gym document
      final docSnapshot =
          await fakeFirestore.collection('gym').doc(gymId).get();
      final gymData = Gym.fromFirestore(docSnapshot, null);

      // Add a new activity
      final newActivity = Activity(
        id: 'new_activity_id',
        description: 'New Activity Description',
      );

      final updatedGym = Gym(
        id: gymId,
        name: gymData.name,
        description: gymData.description,
        imageUrl: gymData.imageUrl,
        activities: [...gymData.activities, newActivity],
      );

      // Act
      await gymService.setActivity(updatedGym);

      // Assert
      final updatedDoc = await fakeFirestore.collection('gym').doc(gymId).get();
      final updatedGymData = updatedDoc.data() as Map<String, dynamic>;

      final List<dynamic> activities = updatedGymData['activities'];
      expect(activities.length, 2); // Original activity + new one

      final Map<String, dynamic> addedActivity = activities.firstWhere(
        (activity) => activity['id'] == 'new_activity_id',
        orElse: () => {},
      );

      expect(addedActivity['description'], 'New Activity Description');
    });

    test('deleteActivity removes an activity from a gym', () async {
      // Arrange
      final gymIds = await _addTestGyms();
      final gymId = gymIds[0];

      // Get the gym document
      final docSnapshot =
          await fakeFirestore.collection('gym').doc(gymId).get();
      final gymData = Gym.fromFirestore(docSnapshot, null);

      final activityToDelete = gymData.activities[0];

      // Act
      await gymService.deleteActivity(gymData, activityToDelete);

      // Assert
      final updatedDoc = await fakeFirestore.collection('gym').doc(gymId).get();
      final updatedGymData = updatedDoc.data() as Map<String, dynamic>;

      final List<dynamic> activities = updatedGymData['activities'] ?? [];
      expect(activities.isEmpty, isTrue);
    });

    test('uploadImage successfully uploads image to Imgur', () async {
      // Arrange
      final base64Image =
          'R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs='; // Tiny base64 image
      final mockResponse = http.Response(
        json.encode({
          'success': true,
          'data': {'link': 'https://imgur.com/testimage.jpg'},
        }),
        200,
      );

      // Mock the HTTP response
      when(mockHttpClient.send(any)).thenAnswer((_) async {
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(utf8.encode(mockResponse.body)),
          mockResponse.statusCode,
          headers: {'content-type': 'application/json'},
        );
        return mockStreamedResponse;
      });

      // Act
      final imageUrl = await gymService.uploadImage(base64Image);

      // Assert
      expect(imageUrl, 'https://imgur.com/testimage.jpg');

      // Verify the request was made with the right parameters
      verify(mockHttpClient.send(any)).called(1);
    });

    test('uploadImage throws exception when upload fails', () async {
      // Arrange
      final base64Image =
          'R0lGODlhAQABAIAAAAUEBAAAACwAAAAAAQABAAACAkQBADs='; // Tiny base64 image
      final mockResponse = http.Response(
        json.encode({
          'success': false,
          'data': {'error': 'Upload failed'},
        }),
        400,
      );

      // Mock the HTTP response
      when(mockHttpClient.send(any)).thenAnswer((_) async {
        final mockStreamedResponse = http.StreamedResponse(
          Stream.value(utf8.encode(mockResponse.body)),
          mockResponse.statusCode,
          headers: {'content-type': 'application/json'},
        );
        return mockStreamedResponse;
      });

      // Act & Assert
      expect(() => gymService.uploadImage(base64Image), throwsException);

      // Verify the request was made
      verify(mockHttpClient.send(any)).called(1);
    });

    test('Gym copyWith creates a copy with modified values', () {
      // Arrange
      final gym = Gym(
        id: '1',
        name: 'Gym A',
        description: 'Description A',
        address: 'Address A',
        phone: '1234567890',
        activities: [],
        imageUrl: 'https://example.com/image.jpg',
        openTime: DateTime(2023, 1, 1, 8, 0),
        closeTime: DateTime(2023, 1, 1, 20, 0),
      );

      // Act
      final updatedGym = gym.copyWith(
        name: 'Updated Gym A',
        description: 'Updated Description A',
      );

      // Assert
      expect(updatedGym.id, gym.id);
      expect(updatedGym.name, 'Updated Gym A');
      expect(updatedGym.description, 'Updated Description A');
      expect(updatedGym.address, gym.address);
      expect(updatedGym.phone, gym.phone);
      expect(updatedGym.activities, gym.activities);
      expect(updatedGym.imageUrl, gym.imageUrl);
      expect(updatedGym.openTime, gym.openTime);
      expect(updatedGym.closeTime, gym.closeTime);
    });
  });
}
