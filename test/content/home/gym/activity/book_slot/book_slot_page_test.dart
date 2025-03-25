import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/book_slot_page.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_card.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Create mocks providers
class MockSlotProvider extends Mock implements SlotProvider {}

class MockUserProvider extends Mock implements UserProvider {}

class MockGymProvider extends Mock implements GymProvider {}

void main() {
  MockSlotProvider mockSlotProvider = MockSlotProvider();
  MockUserProvider mockUserProvider = MockUserProvider();
  MockGymProvider mockGymProvider = MockGymProvider();

  setUp(() {
    when(mockGymProvider.gymList).thenReturn([
      Gym(name: 'Gym 1', activities: [Activity(name: 'Activity 1')]),
    ]);
  });

  group('BookSlotPage tests', () {
    User user = User(uid: 'u1', email: '');

    testWidgets(
      'should display a loading indicator when the slot list is null',
      (WidgetTester tester) async {
        // Stub the nextSlots to return null
        when(mockSlotProvider.nextSlots).thenReturn(null);
        when(mockUserProvider.user).thenReturn(user);

        // Build the widget
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SlotProvider>.value(
                value: mockSlotProvider,
              ),
              ChangeNotifierProvider<UserProvider>.value(
                value: mockUserProvider,
              ),
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ],
            child: MaterialApp(
              home: BookSlotPage(gymIndex: 0, activityIndex: 0),
            ),
          ),
        );

        // Find the loading indicator
        final loadingIndicatorFinder = find.byType(CircularProgressIndicator);

        // Expect the loading indicator to be displayed
        expect(loadingIndicatorFinder, findsOneWidget);
      },
    );

    testWidgets(
      'should display that no slots are available if slot list is empty',
      (WidgetTester tester) async {
        // Stub the nextSlots to return an empty list
        when(mockSlotProvider.nextSlots).thenReturn([]);
        when(mockUserProvider.user).thenReturn(user);

        // Build the widget
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SlotProvider>.value(
                value: mockSlotProvider,
              ),
              ChangeNotifierProvider<UserProvider>.value(
                value: mockUserProvider,
              ),
              ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ],
            child: MaterialApp(
              home: BookSlotPage(gymIndex: 0, activityIndex: 0),
            ),
          ),
        );

        // Find the text widget
        final textFinder = find.text('No slots available');

        // Expect the text widget to be displayed
        expect(textFinder, findsOneWidget);
      },
    );

    testWidgets('should display the book slot page with a slot card', (
      WidgetTester tester,
    ) async {
      // Stub the nextSlots to return fake data
      when(
        mockSlotProvider.nextSlots,
      ).thenReturn([Slot(id: 's1', start: DateTime(10, 10))]);
      when(mockUserProvider.user).thenReturn(user);

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
          ],
          child: MaterialApp(home: BookSlotPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Find the slot card
      final slotCardFinder = find.byType(SlotCard);

      // Expect the slot card to be displayed
      expect(slotCardFinder, findsOneWidget);
    });
  });
}
