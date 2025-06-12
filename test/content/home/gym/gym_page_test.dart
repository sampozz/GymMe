import 'package:dima_project/models/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/models/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:dima_project/providers/instructor_provider.dart';
import 'package:dima_project/providers/gym_provider.dart';
import 'package:dima_project/providers/screen_provider.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../provider_test.mocks.dart';

void main() {
  group('GymPage tests', () {
    testWidgets('should display the gym page', (WidgetTester tester) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final screenProvider = MockScreenProvider();

      when(gymProvider.gymList).thenReturn([
        Gym(
          id: '1',
          name: 'Test Gym',
          description: 'Test Description',
          activities: [
            Activity(
              id: '1',
              title: 'Test Activity',
              description: 'Test Activity Description',
            ),
          ],
        ),
      ]);

      when(userProvider.user).thenReturn(User(uid: '1', isAdmin: true));
      when(screenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScreenProvider>.value(value: screenProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
          ],
          child: MaterialApp(home: GymPage(gymIndex: 0)),
        ),
      );

      // Verify that the gym name and description are displayed
      expect(find.text('Test Gym'), findsAtLeast(1));
    });

    testWidgets('should navigate to NewGym when modify button is pressed', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final screenProvider = MockScreenProvider();

      when(gymProvider.gymList).thenReturn([
        Gym(
          id: '1',
          name: 'Test Gym',
          description: 'Test Description',
          activities: [],
        ),
      ]);

      when(userProvider.user).thenReturn(User(uid: '1', isAdmin: true));
      when(screenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScreenProvider>.value(value: screenProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
          ],
          child: MaterialApp(home: GymPage(gymIndex: 0)),
        ),
      );

      // Wait for the widget to build completely
      await tester.pumpAndSettle();

      // Instead of using dragUntilVisible which is causing the error,
      // let's directly scroll to the bottom where admin actions should be
      final scrollable = find.byType(Scrollable).first;

      // Scroll to the bottom several times to ensure we reach the admin section
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollable, const Offset(0, -500));
        await tester.pumpAndSettle();

        // If we find the button, break out of the loop
        if (find.text('Modify gym').evaluate().isNotEmpty) {
          break;
        }
      }

      // Ensure the modify gym button is visible
      expect(find.text('Modify gym'), findsOneWidget);

      // Tap the modify gym button
      await tester.tap(find.text('Modify gym'));
      await tester.pumpAndSettle();

      // Verify that the NewGym page was pushed onto the navigation stack
      expect(find.byType(NewGym), findsOneWidget);
    });

    testWidgets('tap should navigate to new activity page', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final screenProvider = MockScreenProvider();
      final instructorProvider = MockInstructorProvider();

      when(gymProvider.gymList).thenReturn([
        Gym(
          id: '1',
          name: 'Test Gym',
          description: 'Test Description',
          activities: [],
        ),
      ]);

      when(userProvider.user).thenReturn(User(uid: '1', isAdmin: true));
      when(screenProvider.useMobileLayout).thenReturn(true);
      when(instructorProvider.instructorList).thenReturn([]);

      when(gymProvider.gymList).thenReturn([
        Gym(
          id: '1',
          name: 'Test Gym',
          description: 'Test Description',
          activities: [],
        ),
      ]);

      when(userProvider.user).thenReturn(User(uid: '1', isAdmin: true));
      when(screenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<InstructorProvider>.value(
              value: instructorProvider,
            ),
            ChangeNotifierProvider<ScreenProvider>.value(value: screenProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
          ],
          child: MaterialApp(home: GymPage(gymIndex: 0)),
        ),
      );

      // Wait for the widget to build completely
      await tester.pumpAndSettle();

      // Scroll to the bottom several times to ensure we reach the admin section
      final scrollable = find.byType(Scrollable).first;
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollable, const Offset(0, -500));
        await tester.pumpAndSettle();
        if (find.text('Add activity').evaluate().isNotEmpty) {
          break;
        }
      }

      // Ensure the add activity button is visible
      expect(find.text('Add activity'), findsOneWidget);

      // Tap the add activity button
      await tester.tap(find.text('Add activity'));
      await tester.pumpAndSettle();

      // Verify that the NewActivity page was pushed onto the navigation stack
      expect(find.byType(NewActivity), findsOneWidget);
    });

    testWidgets('tap should show Delete gym alert dialog', (
      WidgetTester tester,
    ) async {
      // Mock the UserProvider and GymProvider
      final userProvider = MockUserProvider();
      final gymProvider = MockGymProvider();
      final screenProvider = MockScreenProvider();

      when(gymProvider.gymList).thenReturn([
        Gym(
          id: '1',
          name: 'Test Gym',
          description: 'Test Description',
          activities: [],
        ),
      ]);

      when(userProvider.user).thenReturn(User(uid: '1', isAdmin: true));
      when(screenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<ScreenProvider>.value(value: screenProvider),
            ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ChangeNotifierProvider<GymProvider>.value(value: gymProvider),
          ],
          child: MaterialApp(home: GymPage(gymIndex: 0)),
        ),
      );

      // Wait for the widget to build completely
      await tester.pumpAndSettle();

      // Scroll to the bottom several times to ensure we reach the admin section
      final scrollable = find.byType(Scrollable).first;
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollable, const Offset(0, -500));
        await tester.pumpAndSettle();
        if (find.text('Delete gym').evaluate().isNotEmpty) {
          break;
        }
      }

      // Ensure the delete gym button is visible
      expect(find.text('Delete gym'), findsOneWidget);

      // Tap the delete gym button
      await tester.tap(find.text('Delete gym'));
      await tester.pumpAndSettle();

      // Verify that the alert dialog is displayed
      expect(find.text('Delete Gym'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify that the gym was deleted
      verify(gymProvider.removeGym(any)).called(1);
    });
  });
}
