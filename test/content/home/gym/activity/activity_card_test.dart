import 'package:dima_project/content/home/gym/activity/activity_card.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityCard tests', () {
    testWidgets('should display the activity card with the activity name', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: ActivityCard(
            gym: Gym(),
            activity: Activity(name: 'Activity 1'),
          ),
        ),
      );

      // Find the activity name
      final activityNameFinder = find.text('Activity 1');

      // Expect the activity name to be displayed
      expect(activityNameFinder, findsOneWidget);
    });
  });
}
