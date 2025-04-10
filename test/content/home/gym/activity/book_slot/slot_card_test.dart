import 'package:dima_project/content/home/gym/activity/book_slot/slot_card.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlotCard tests', () {
    testWidgets('should display the slot card with the slot start date', (
      WidgetTester tester,
    ) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: SlotCard(slot: Slot(startTime: DateTime(2021, 1, 1))),
        ),
      );

      // Find the slot start date
      final slotStartDateFinder = find.text('Slot 2021-01-01 00:00:00.000');

      // Expect the slot start date to be displayed
      expect(slotStartDateFinder, findsOneWidget);
    });
  });
}
