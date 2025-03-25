import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockGymProvider extends Mock implements GymProvider {}

void main() {
  group('GymCard tests', () {
    testWidgets('should display the gym name', (WidgetTester tester) async {
      // Create an instance of the mock provider
      final mockGymProvider = MockGymProvider();

      // Stub the gym list to return a gym
      when(mockGymProvider.gymList).thenReturn([
        Gym(name: 'Gym 1', address: 'Address 1', phone: '1234567890'),
      ]);

      // Build the GymCard widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
          ],
          child: MaterialApp(home: GymCard(gymIndex: 0)),
        ),
      );

      // Find the gym name
      final gymNameFinder = find.text('Gym 1');

      // Expect the gym name to be displayed
      expect(gymNameFinder, findsOneWidget);
    });
  });
}
