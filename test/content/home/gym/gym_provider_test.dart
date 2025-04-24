import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'gym_provider_test.mocks.dart';

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
      when(mockGymService.updateGym(updatedGym)).thenAnswer((_) async => null);

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
      when(mockGymService.deleteGym(gymId)).thenAnswer((_) async => null);

      // Populate the gym list (needed to initialize the gym list)
      await gymProvider.getGymList();

      // Delete the gym
      await gymProvider.removeGym(testGym);

      // Verify that the gym was removed from the gym list
      expect(gymProvider.gymList!.length, 0);
    });
  });
}
