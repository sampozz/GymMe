import 'package:gymme/models/activity_model.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../service_test.mocks.dart';

void main() {
  late MockGymService mockGymService;

  setUp(() {
    mockGymService = MockGymService();
  });

  group('GymProvider', () {
    test('should return a list of gyms', () async {
      var gymProvider = GymProvider(gymService: mockGymService);
      var gymList = [
        Gym(name: 'Gym 1', address: 'Address 1'),
        Gym(name: 'Gym 2', address: 'Address 2'),
      ];
      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      var res = await gymProvider.getGymList();
      expect(res, gymList);
    });

    test('should add a gym to the gym list', () async {
      // Create test objects
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(name: 'Gym 1', address: 'Address 1');
      var newGym = Gym(id: '1', name: 'Gym 2', address: 'Address 2');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      when(mockGymService.addGym(newGym)).thenAnswer((_) async => '1');

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Add a new gym
      await gymProvider.addGym(newGym);

      // Verify that the gym was added to the gym list
      expect(gymProvider.gymList!.first, newGym);
    });

    test('should update a gym in the gym list', () async {
      // Create test objects
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(name: 'Gym 1', address: 'Address 1');
      var updatedGym = Gym(name: 'Gym 2', address: 'Address 2');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      when(mockGymService.updateGym(updatedGym)).thenAnswer((_) async {});

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Update the gym
      await gymProvider.updateGym(updatedGym);

      // Verify that the gym was updated in the gym list
      expect(gymProvider.gymList!.first, updatedGym);
    });

    test('should delete a gym from the gym list', () async {
      // Create test objects
      var gymId = '1';
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(id: gymId, name: 'Gym 1', address: 'Address 1');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      when(mockGymService.deleteGym(gymId)).thenAnswer((_) async {});

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Delete the gym
      await gymProvider.removeGym(testGym);

      // Verify that the gym was removed from the gym list
      expect(gymProvider.gymList!.length, 0);
    });

    test('should add an activity to the gym list', () async {
      // Create test objects
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(
        name: 'Gym 1',
        address: 'Address 1',
        activities: List<Activity>.empty(growable: true),
      );
      var activity = Activity(title: 'Yoga', description: 'Yoga class');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      when(mockGymService.setActivity(testGym)).thenAnswer((_) async {});

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Add an activity
      await gymProvider.addActivity(testGym, activity);

      // Verify that the activity was added to the gym list
      expect(gymProvider.gymList!.first.activities.first, activity);
    });

    test('should update an activity in the gym list', () async {
      // Arrange
      final gym1 = Gym(
        id: '1',
        name: 'Test Gym 1',
        activities: [
          Activity(id: 'a1', title: 'Activity 1'),
          Activity(id: 'a2', title: 'Activity 2'),
        ],
      );

      final gym2 = Gym(
        id: '2',
        name: 'Test Gym 2',
        activities: [Activity(id: 'a3', title: 'Activity 3')],
      );

      final updatedActivity = Activity(
        id: 'a2',
        title: 'Updated Activity 2',
        description: 'New description',
      );

      // Set initial state
      when(mockGymService.fetchGymList()).thenAnswer((_) async => [gym1, gym2]);
      final gymProvider = GymProvider(gymService: mockGymService);
      gymProvider.getGymList();

      // Mock the service call
      when(
        mockGymService.setActivity(any),
      ).thenAnswer((_) async => Future.value());

      // Act
      await gymProvider.updateActivity(gym1, updatedActivity);

      // Assert
      // Verify the service was called with the correct gym
      verify(mockGymService.setActivity(gym1)).called(1);

      // Verify loading state was properly managed
      expect(gymProvider.isLoading, false);

      // Verify the activity was updated in the gym list
      final updatedGym = gymProvider.gymList!.firstWhere(
        (g) => g.id == gym1.id,
      );
      final activity = updatedGym.activities.firstWhere(
        (a) => a.id == updatedActivity.id,
      );

      expect(activity.title, equals('Updated Activity 2'));
      expect(activity.description, equals('New description'));

      // Verify other gyms weren't affected
      final otherGym = gymProvider.gymList!.firstWhere((g) => g.id == gym2.id);
      expect(otherGym.activities.length, equals(1));
      expect(otherGym.activities[0].id, equals('a3'));
    });

    test('should delete an activity from the gym list', () async {
      // Create test objects
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(
        name: 'Gym 1',
        address: 'Address 1',
        activities: List<Activity>.empty(growable: true),
      );
      var activity = Activity(title: 'Yoga', description: 'Yoga class');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      when(mockGymService.setActivity(testGym)).thenAnswer((_) async {});

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Add an activity
      await gymProvider.addActivity(testGym, activity);

      // Delete the activity
      await gymProvider.removeActivity(testGym, activity);

      // Verify that the activity was removed from the gym list
      expect(gymProvider.gymList!.first.activities.length, 0);
    });

    test('getGymIndex', () async {
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(name: 'Gym 1', address: 'Address 1');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Get the index of the gym
      var index = gymProvider.getGymIndex(testGym);

      // Verify that the index is correct
      expect(index, 0);
    });

    test('uploadImage', () async {
      var gymProvider = GymProvider(gymService: mockGymService);
      var testGym = Gym(name: 'Gym 1', address: 'Address 1');
      var gymList = [testGym];

      when(mockGymService.fetchGymList()).thenAnswer((_) async => gymList);
      when(
        mockGymService.uploadImage(any),
      ).thenAnswer((_) async => 'image_url');

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Upload an image
      var res = await gymProvider.uploadImage('image_base64');

      // Verify that the image was uploaded
      expect(res, 'image_url');
    });
  });
}
