import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/book_slot_page.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_card.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

// Create a mock of SlotProvider
class MockSlotProvider extends Mock implements SlotProvider {}

void main() {
  group('BookSlotPage tests', () {
    Gym gym = Gym(id: 'g1', name: 'Gym 1');
    Activity activity = Activity(id: 'a1', name: 'Activity 1');

    testWidgets(
      'should display a loading indicator when the slot list is null',
      (WidgetTester tester) async {
        // Create an instance of the mock provider
        final mockSlotProvider = MockSlotProvider();

        // Stub the nextSlots to return null
        when(mockSlotProvider.nextSlots).thenReturn(null);

        // Build the widget
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SlotProvider>.value(
                value: mockSlotProvider,
              ),
            ],
            child: MaterialApp(
              home: BookSlotPage(gym: gym, activity: activity),
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
        // Create an instance of the mock provider
        final mockSlotProvider = MockSlotProvider();

        // Stub the nextSlots to return an empty list
        when(mockSlotProvider.nextSlots).thenReturn([]);

        // Build the widget
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<SlotProvider>.value(
                value: mockSlotProvider,
              ),
            ],
            child: MaterialApp(
              home: BookSlotPage(gym: gym, activity: activity),
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
      // Create an instance of the mock provider
      final mockSlotProvider = MockSlotProvider();

      // Stub the nextSlots to return fake data
      when(
        mockSlotProvider.nextSlots,
      ).thenReturn([Slot(id: 's1', start: DateTime(10, 10))]);

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
          ],
          child: MaterialApp(home: BookSlotPage(gym: gym, activity: activity)),
        ),
      );

      // Find the slot card
      final slotCardFinder = find.byType(SlotCard);

      // Expect the slot card to be displayed
      expect(slotCardFinder, findsOneWidget);
    });
  });
}
