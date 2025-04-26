import 'package:dima_project/content/home/gym/activity/activity_card.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../provider_test.mocks.dart';

void main() {
  group('ActivityCard tests', () {
    testWidgets('should display the activity card with the activity name', (
      WidgetTester tester,
    ) async {
      // Create an instance of the mock provider
      final mockGymProvider = MockGymProvider();

      // Stub the gym list to return a gym
      when(mockGymProvider.gymList).thenReturn([
        Gym(name: 'Gym 1', activities: [Activity(title: 'Activity 1')]),
      ]);

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
          ],
          child: MaterialApp(home: ActivityCard(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Find the activity name
      final activityNameFinder = find.text('Activity 1');

      // Expect the activity name to be displayed
      expect(activityNameFinder, findsOneWidget);
    });
  });
}
