import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GymCard tests', () {
    testWidgets('should display the gym name', (WidgetTester tester) async {
      // Build the GymCard widget
      await tester.pumpWidget(
        MaterialApp(home: GymCard(gym: Gym(name: 'Gym 1'))),
      );

      // Find the gym name
      final gymNameFinder = find.text('Gym 1');

      // Expect the gym name to be displayed
      expect(gymNameFinder, findsOneWidget);
    });
  });
}
