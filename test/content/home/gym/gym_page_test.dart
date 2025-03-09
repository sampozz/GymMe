import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GymPage tests', () {
    testWidgets('should display the gym name', (WidgetTester tester) async {
      // Build the GymPage widget
      await tester.pumpWidget(
        MaterialApp(home: GymPage(gym: Gym(name: 'Gym 1'))),
      );

      // Find the gym name contained in the text widget
      final gymNameFinder = find.text('Welcome to the gym Gym 1!');

      // Expect the gym name to be displayed
      expect(gymNameFinder, findsOneWidget);
    });
  });
}
