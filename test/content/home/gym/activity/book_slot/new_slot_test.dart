import 'package:gymme/content/home/gym/activity/slots/new_slot.dart';
import 'package:gymme/models/slot_model.dart';
import 'package:gymme/providers/slot_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../../provider_test.mocks.dart';

void main() {
  late MockSlotProvider mockSlotProvider;

  setUp(() {
    mockSlotProvider = MockSlotProvider();
  });

  group('NewSlot widget tests', () {
    testWidgets('should display form elements for creating a new slot', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(gymId: 'gym1', activityId: 'activity1'),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Create new slot'), findsOneWidget);
      expect(find.byKey(Key('dateField')), findsOneWidget);
      expect(find.byKey(Key('startTimeField')), findsOneWidget);
      expect(find.byKey(Key('endTimeField')), findsOneWidget);
      expect(find.byKey(Key('maxUsersField')), findsOneWidget);
      expect(find.byKey(Key('roomField')), findsOneWidget);
      expect(find.text('Create Slot'), findsOneWidget);
    });

    testWidgets('should display form elements with data when editing a slot', (
      WidgetTester tester,
    ) async {
      // Arrange
      final DateTime now = DateTime.now();
      final DateTime end = now.add(Duration(hours: 1));
      final Slot existingSlot = Slot(
        id: 'slot1',
        gymId: 'gym1',
        activityId: 'activity1',
        startTime: now,
        endTime: end,
        maxUsers: 10,
        room: 'Room 101',
        bookedUsers: ['user1'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(
              gymId: 'gym1',
              activityId: 'activity1',
              oldSlot: existingSlot,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.text('Edit slot'), findsOneWidget);
      expect(
        find.text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(now)),
        findsOneWidget,
      );
      expect(
        find.text(DateFormat(DateFormat.HOUR24_MINUTE).format(now)),
        findsOneWidget,
      );
      expect(
        find.text(DateFormat(DateFormat.HOUR24_MINUTE).format(end)),
        findsOneWidget,
      );
      expect(find.text('10'), findsOneWidget);
      expect(find.text('Room 101'), findsOneWidget);
      expect(find.text('Update Slot'), findsOneWidget);
      // Recurrence section shouldn't be visible when editing
      expect(find.text('Repeat until'), findsNothing);
    });

    testWidgets('should show date picker when tap on date', (
      WidgetTester tester,
    ) async {
      // Arrange - need to stub the provider method
      when(
        mockSlotProvider.createSlot(any, any, any),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(gymId: 'gym1', activityId: 'activity1'),
          ),
        ),
      );

      // Act - tap the date field
      await tester.tap(find.byKey(Key('dateField')));
      await tester.pumpAndSettle();

      // Assert - check if the date picker is displayed
      expect(find.byType(DatePickerDialog), findsOneWidget);

      // Simulate selecting a date
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();
      // Assert - check if the selected date is displayed
      expect(
        find.text(DateFormat(DateFormat.YEAR_MONTH_DAY).format(DateTime.now())),
        findsOneWidget,
      );
    });

    testWidgets('should show time picker when tap on start time', (
      WidgetTester tester,
    ) async {
      // Arrange - need to stub the provider method
      when(
        mockSlotProvider.createSlot(any, any, any),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(gymId: 'gym1', activityId: 'activity1'),
          ),
        ),
      );

      // Act - tap the start time field
      await tester.tap(find.byKey(Key('startTimeField')));
      await tester.pumpAndSettle();

      // Assert - check if the time picker is displayed
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Simulate selecting a time
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();
      // Assert - check if the selected time is displayed
      expect(
        find.text(DateFormat(DateFormat.HOUR24_MINUTE).format(DateTime.now())),
        findsOneWidget,
      );
    });

    testWidgets('should call updateSlot when editing an existing slot', (
      WidgetTester tester,
    ) async {
      // Arrange
      final DateTime now = DateTime.now();
      final DateTime end = now.add(Duration(hours: 1));
      final Slot existingSlot = Slot(
        id: 'slot1',
        gymId: 'gym1',
        activityId: 'activity1',
        startTime: now,
        endTime: end,
        maxUsers: 10,
        room: 'Room 101',
      );

      when(mockSlotProvider.updateSlot(any)).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(
              gymId: 'gym1',
              activityId: 'activity1',
              oldSlot: existingSlot,
            ),
          ),
        ),
      );

      // Act - tap the update button
      // For a complete test, we would modify the form fields first
      // This is a simplified test structure
      await tester.tap(find.text('Update Slot'));
      await tester.pump();

      // In a full implementation, we would expect verify the updateSlot method was called
      verify(mockSlotProvider.updateSlot(any)).called(1);
    });

    testWidgets('should call createSlot when creating a new slot', (
      WidgetTester tester,
    ) async {
      // Arrange
      when(
        mockSlotProvider.createSlot(any, any, any),
      ).thenAnswer((_) async => {});

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(gymId: 'gym1', activityId: 'activity1'),
          ),
        ),
      );

      // Act - tap the create button
      final button = find.text('Create Slot');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();

      // Assert - verify that createSlot was called
      verify(mockSlotProvider.createSlot(any, any, any)).called(1);
    });

    testWidgets('should handle recurrence selection', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<SlotProvider>.value(
            value: mockSlotProvider,
            child: NewSlot(gymId: 'gym1', activityId: 'activity1'),
          ),
        ),
      );

      // Act - select a recurrence option
      await tester.tap(find.text('None'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Weekly').last);
      await tester.pumpAndSettle();

      // Assert - "Repeat until" field should be enabled
      expect(find.text('Repeat until'), findsOneWidget);
      final TextField untilField = tester.widget(find.byType(TextField).at(5));
      expect(untilField.enabled, isTrue);
    });
  });
}
