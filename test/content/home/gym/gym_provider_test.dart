import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'gym_provider_test.mocks.dart';

@GenerateMocks([GymService])
void main() {
  late MockGymService mockGymService;

  setUp(() {
    mockGymService = MockGymService();
  });

  group('GymProvider tests', () {
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
  });
}
