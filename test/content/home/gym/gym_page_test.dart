import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserProvider extends Mock implements UserProvider {}

class MockGymProvider extends Mock implements GymProvider {}

void main() {
  group('GymPage tests', () {
    testWidgets('should display the gym name', (WidgetTester tester) async {
      // Create an instance of the mock provider
      final mockUserProvider = MockUserProvider();
      final mockGymProvider = MockGymProvider();

      // Stub the user to return a user
      when(mockUserProvider.user).thenReturn(User(uid: '1'));
      when(mockGymProvider.gymList).thenReturn([
        Gym(name: 'Gym 1', address: 'Address 1', phone: '1234567890'),
      ]);

      // Build the GymPage widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
          ],
          child: MaterialApp(home: GymPage(gymIndex: 0)),
        ),
      );

      // Find the gym name contained in the text widget
      final gymNameFinder = find.text('Welcome to the gym Gym 1!');

      // Expect the gym name to be displayed
      expect(gymNameFinder, findsOneWidget);
    });
  });
}
