import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/content/home/home.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Create a mock of GymProvider
class MockGymProvider extends Mock implements GymProvider {}

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  group('Home tests', () {
    testWidgets(
      'should display a loading indicator when the gym list is null',
      (WidgetTester tester) async {
        // Create an instance of the mock provider
        final mockGymProvider = MockGymProvider();

        // Stub the gymList to return fake data
        when(mockGymProvider.gymList).thenReturn(null);

        // Build the widget with the mock provider
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ],
            child: MaterialApp(home: Home()),
          ),
        );

        // Find the loading indicator
        final loadingIndicatorFinder = find.byType(CircularProgressIndicator);

        // Expect the loading indicator to be displayed
        expect(loadingIndicatorFinder, findsOneWidget);
      },
    );

    testWidgets('should display the gym list when the gym list is not null', (
      WidgetTester tester,
    ) async {
      // Create an instance of the mock provider
      final mockUserProvider = MockUserProvider();
      final mockGymProvider = MockGymProvider();

      // Stub the gymList to return fake data
      when(mockGymProvider.gymList).thenReturn([Gym(name: 'Gym 1')]);
      when(mockUserProvider.user).thenReturn(User());

      // Build the widget with the mock provider
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(home: Home()),
        ),
      );

      // Find the gym card
      final gymCardFinder = find.byType(GymCard);

      // Expect the gym card to be displayed
      expect(gymCardFinder, findsOneWidget);
    });
  });
}
