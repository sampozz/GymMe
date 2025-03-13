import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/content/home/gym/gym_page.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  group('GymPage tests', () {
    testWidgets('should display the gym name', (WidgetTester tester) async {
      // Create an instance of the mock provider
      final mockUserProvider = MockUserProvider();

      // Stub the user to return a user
      when(mockUserProvider.user).thenReturn(User(uid: '1'));

      // Build the GymPage widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(home: GymPage(gym: Gym(id: 'g1', name: 'Gym 1'))),
        ),
      );

      // Find the gym name contained in the text widget
      final gymNameFinder = find.text('Welcome to the gym Gym 1!');

      // Expect the gym name to be displayed
      expect(gymNameFinder, findsOneWidget);
    });
  });
}
