import 'package:gymme/content/home/gym/activity/activity_card.dart';
import 'package:gymme/models/activity_model.dart';
import 'package:gymme/content/home/gym/activity/slots/slots_page.dart';
import 'package:gymme/providers/slot_provider.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/providers/instructor_provider.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../firestore_test.mocks.dart';
import '../../../../provider_test.mocks.dart';
import '../../../../service_test.mocks.dart';

void main() {
  group('ActivityCard tests', () {
    test('Activity toFirestore should return a map', () {
      final activity = Activity(
        id: '1',
        title: 'Yoga Class',
        description: 'A relaxing yoga class.',
        price: 20.0,
        instructorId: 'instructor_1',
      );

      final map = activity.toFirestore();

      expect(map['id'], '1');
      expect(map['title'], 'Yoga Class');
      expect(map['description'], 'A relaxing yoga class.');
      expect(map['price'], 20.0);
      expect(map['instructorId'], 'instructor_1');
    });

    test(
      'Activity copyWith should return a new instance with updated values',
      () {
        final activity = Activity(
          id: '1',
          title: 'Yoga Class',
          description: 'A relaxing yoga class.',
          price: 20.0,
          instructorId: 'instructor_1',
        );

        final updatedActivity = activity.copyWith(
          title: 'Pilates Class',
          price: 25.0,
        );

        expect(updatedActivity.id, '1');
        expect(updatedActivity.title, 'Pilates Class');
        expect(updatedActivity.description, 'A relaxing yoga class.');
        expect(updatedActivity.price, 25.0);
        expect(updatedActivity.instructorId, 'instructor_1');
      },
    );

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

    testWidgets('should navigate to activity page when tap on card', (
      WidgetTester tester,
    ) async {
      // Create an instance of the mock provider
      final mockGymProvider = MockGymProvider();
      final mockUserProvider = MockUserProvider();
      final MockInstructorProvider mockInstructorProvider =
          MockInstructorProvider();
      final mockSlotProvider = SlotProvider(
        gymId: '1',
        activityId: '1',
        firebaseAuth: MockFirebaseAuth(),
        slotService: MockSlotService(),
      );

      // Stub the gym list to return a gym
      when(mockGymProvider.gymList).thenReturn([
        Gym(
          id: '1',
          name: 'Gym 1',
          activities: [Activity(title: 'Activity 1')],
        ),
      ]);

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: ActivityCard(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Tap on the card
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verify that the navigation occurred
      expect(find.byType(SlotsPage), findsOneWidget);
    });
  });
}
