import 'package:dima_project/models/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/models/gym_model.dart';
import 'package:dima_project/models/instructor_model.dart';
import 'package:dima_project/providers/instructor_provider.dart';
import 'package:dima_project/content/home/gym/activity/instructors/instructors_page.dart';
import 'package:dima_project/providers/gym_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../provider_test.mocks.dart';

void main() {
  group('NewActivity', () {
    final mockGymProvider = MockGymProvider();
    final mockInstructorProvider = MockInstructorProvider();

    setUp(() {
      when(mockGymProvider.isLoading).thenReturn(false);
      when(
        mockInstructorProvider.instructorList,
      ).thenReturn([Instructor(id: 'instructor_1', name: 'John Doe')]);
    });

    testWidgets('renders NewActivity widget', (WidgetTester tester) async {
      // Mock the Gym and Activity objects
      final gym = Gym(id: '1', name: 'Test Gym');
      final activity = Activity(
        id: '1',
        title: 'Yoga Class',
        description: 'A relaxing yoga class.',
        price: 20.0,
        instructorId: 'instructor_1',
      );

      // Build the NewActivity widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: NewActivity(gym: gym, activity: activity),
          ),
        ),
      );

      // Verify that the title and description fields are present
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Yoga Class'), findsOneWidget);
      expect(find.text('A relaxing yoga class.'), findsOneWidget);
    });

    testWidgets('is loading shows a circular progress indicator', (
      WidgetTester tester,
    ) async {
      // Mock the Gym and Activity objects
      final gym = Gym(id: '1', name: 'Test Gym');
      final activity = Activity(
        id: '1',
        title: 'Yoga Class',
        description: 'A relaxing yoga class.',
        price: 20.0,
        instructorId: 'instructor_1',
      );

      // Mock the loading state
      when(mockGymProvider.isLoading).thenReturn(true);

      // Build the NewActivity widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: NewActivity(gym: gym, activity: activity),
          ),
        ),
      );

      // Verify that a CircularProgressIndicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to instructors page when tap', (
      WidgetTester tester,
    ) async {
      // Mock the Gym and Activity objects
      final gym = Gym(id: '1', name: 'Test Gym');
      final activity = Activity(
        id: '1',
        title: 'Yoga Class',
        description: 'A relaxing yoga class.',
        price: 20.0,
        instructorId: 'instructor_1',
      );

      // Build the NewActivity widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: NewActivity(gym: gym, activity: activity),
          ),
        ),
      );

      // Tap on the instructor field
      await tester.tap(find.text('Edit instructors'));
      await tester.pumpAndSettle();

      // Verify that the InstructorsPage is pushed
      expect(find.byType(InstructorsPage), findsOneWidget);
    });

    testWidgets('Add activity should call addActivity', (
      WidgetTester tester,
    ) async {
      // Mock the Gym and Activity objects
      final gym = Gym(id: '1', name: 'Test Gym');

      // Build the NewActivity widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: NewActivity(gym: gym, activity: null),
          ),
        ),
      );

      // Enter text into the title field
      await tester.enterText(
        find.byKey(Key('titleField')),
        'New Activity Title',
      );
      await tester.enterText(find.byKey(Key('priceField')), '10.0');

      // Tap the save button
      await tester.tap(find.widgetWithText(TextButton, 'Add activity'));
      await tester.pumpAndSettle();

      // Verify that createActivity was called
      verify(mockGymProvider.addActivity(any, any)).called(1);
    });

    testWidgets('Update activity should call updateActivity', (
      WidgetTester tester,
    ) async {
      // Mock the Gym and Activity objects
      final gym = Gym(id: '1', name: 'Test Gym');
      final activity = Activity(
        id: '1',
        title: 'Yoga Class',
        description: 'A relaxing yoga class.',
        price: 20.0,
        instructorId: 'instructor_1',
      );

      // Build the NewActivity widget
      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: NewActivity(gym: gym, activity: activity),
          ),
        ),
      );

      // Enter text into the title field
      await tester.enterText(
        find.byKey(Key('titleField')),
        'Updated Activity Title',
      );
      await tester.enterText(find.byKey(Key('priceField')), '15.0');

      // Tap the save button
      await tester.tap(find.widgetWithText(TextButton, 'Update activity'));
      await tester.pumpAndSettle();

      // Verify that updateActivity was called
      verify(mockGymProvider.updateActivity(any, any)).called(1);
    });
  });
}
