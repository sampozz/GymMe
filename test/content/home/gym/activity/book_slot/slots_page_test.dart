import 'package:dima_project/providers/bookings_provider.dart';
import 'package:dima_project/models/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/slots/slots_page.dart';
import 'package:dima_project/content/home/gym/activity/slots/new_slot.dart';
import 'package:dima_project/content/home/gym/activity/slots/slot_card.dart';
import 'package:dima_project/models/slot_model.dart';
import 'package:dima_project/providers/slot_provider.dart';
import 'package:dima_project/content/home/gym/activity/new_activity.dart';
import 'package:dima_project/models/gym_model.dart';
import 'package:dima_project/providers/instructor_provider.dart';
import 'package:dima_project/providers/gym_provider.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../../provider_test.mocks.dart';

void main() {
  MockSlotProvider mockSlotProvider = MockSlotProvider();
  MockUserProvider mockUserProvider = MockUserProvider();
  MockGymProvider mockGymProvider = MockGymProvider();
  MockInstructorProvider mockInstructorProvider = MockInstructorProvider();

  setUp(() {
    Activity activity = Activity.fromFirestore({
      'id': 'a1',
      'title': 'Activity 1',
    });
    when(mockGymProvider.gymList).thenReturn([
      Gym(name: 'Gym 1', activities: [activity]),
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
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
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
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
            ],
            child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
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
      ).thenReturn([Slot(id: 's1', startTime: DateTime.now())]);
      when(mockUserProvider.user).thenReturn(user);

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Find the slot card
      final slotCardFinder = find.byType(SlotCard);

      // Expect the slot card to be displayed
      expect(slotCardFinder, findsOneWidget);
    });

    testWidgets('should navigate between dates using tab controller', (
      WidgetTester tester,
    ) async {
      // Setup mock data with slots for different dates
      final today = DateTime.now();
      final tomorrow = today.add(Duration(days: 1));

      Slot todaySlot = Slot(
        id: 's1',
        startTime: today,
        endTime: today.add(Duration(hours: 1)),
        room: 'Room 1',
        maxUsers: 10,
        bookedUsers: ['user2'],
      );

      Slot tomorrowSlot = Slot(
        id: 's2',
        startTime: tomorrow,
        endTime: tomorrow.add(Duration(hours: 1)),
        room: 'Room 2',
        maxUsers: 10,
      );

      when(mockSlotProvider.nextSlots).thenReturn([todaySlot, tomorrowSlot]);
      when(mockUserProvider.user).thenReturn(user);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should show today's slot
      expect(find.text('Room: Room 1'), findsOneWidget);
      expect(find.text('Room: Room 2'), findsNothing);

      // Find and tap tomorrow's tab (index 1)
      await tester.tap(find.text(tomorrow.day.toString()).first);
      await tester.pumpAndSettle();

      // Now should show tomorrow's slot
      expect(find.text('Room: Room 1'), findsNothing);
      expect(find.text('Room: Room 2'), findsOneWidget);
    });

    testWidgets('should show admin actions for admin users', (
      WidgetTester tester,
    ) async {
      // Create an admin user
      User adminUser = User(uid: 'admin1', email: '', isAdmin: true);

      when(
        mockSlotProvider.nextSlots,
      ).thenReturn([Slot(id: 's1', startTime: DateTime.now())]);
      when(mockUserProvider.user).thenReturn(adminUser);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      await tester.pumpAndSettle();

      // Admin buttons should be visible
      expect(find.text('Add slot'), findsOneWidget);
      expect(find.text('Modify activity'), findsOneWidget);
      expect(find.text('Delete activity'), findsOneWidget);
    });

    testWidgets('should not show admin actions for regular users', (
      WidgetTester tester,
    ) async {
      // Regular user (non-admin)
      when(
        mockSlotProvider.nextSlots,
      ).thenReturn([Slot(id: 's1', startTime: DateTime.now())]);
      when(mockUserProvider.user).thenReturn(user); // regular user

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      await tester.pumpAndSettle();

      // Admin buttons should not be visible
      expect(find.text('Add slot'), findsNothing);
      expect(find.text('Modify activity'), findsNothing);
      expect(find.text('Delete activity'), findsNothing);
    });

    testWidgets(
      'should show booking modal when slot is tapped by regular user',
      (WidgetTester tester) async {
        final MockBookingsProvider mockBookingsProvider =
            MockBookingsProvider();
        final slot = Slot(
          id: 's1',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          maxUsers: 10,
        );

        when(mockSlotProvider.nextSlots).thenReturn([slot]);
        when(mockUserProvider.user).thenReturn(user);
        when(mockInstructorProvider.instructorList).thenReturn([]);

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
              ChangeNotifierProvider<InstructorProvider>.value(
                value: mockInstructorProvider,
              ),
              ChangeNotifierProvider<BookingsProvider>.value(
                value: mockBookingsProvider,
              ),
            ],
            child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
          ),
        );

        await tester.pumpAndSettle();

        // Tap on the slot card
        await tester.tap(find.byType(SlotCard));
        await tester.pumpAndSettle();

        // The booking confirmation modal should appear
        expect(find.text('Confirm'), findsOneWidget);

        // Tap on the confirm button
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Verify that the createBooking method was called
        verify(mockBookingsProvider.createBooking(any, any, any)).called(1);
      },
    );

    testWidgets('should show admin slot modal when slot is tapped by admin', (
      WidgetTester tester,
    ) async {
      final slot = Slot(
        id: 's1',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(Duration(hours: 1)),
        maxUsers: 10,
      );

      User adminUser = User(uid: 'admin1', email: '', isAdmin: true);

      when(mockSlotProvider.nextSlots).thenReturn([slot]);
      when(mockUserProvider.user).thenReturn(adminUser);
      when(mockInstructorProvider.instructorList).thenReturn([]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the slot card
      await tester.tap(find.byType(SlotCard));
      await tester.pumpAndSettle();

      // The admin slot modal should appear
      expect(find.text('Delete slot'), findsOneWidget);
    });

    testWidgets('deleteActivity shows a confirmation dialog', (
      WidgetTester tester,
    ) async {
      var user = User(uid: 'u1', email: '', isAdmin: true);
      when(mockUserProvider.user).thenReturn(user);
      when(mockInstructorProvider.instructorList).thenReturn([]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Tap on the delete activity button
      await tester.tap(find.text('Delete activity'));
      await tester.pump();

      // The confirmation dialog should appear
      expect(
        find.text('Are you sure you want to delete this activity?'),
        findsOneWidget,
      );

      // Tap on the confirm button
      await tester.tap(find.text('Delete'));
      await tester.pump();
      // Verify that the deleteActivity method was called
      verify(mockGymProvider.removeActivity(any, any)).called(1);
    });

    testWidgets('Modify activity navigates to new activity page', (
      WidgetTester tester,
    ) async {
      var user = User(uid: 'u1', email: '', isAdmin: true);
      when(mockUserProvider.user).thenReturn(user);
      when(mockInstructorProvider.instructorList).thenReturn([]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Tap on the modify activity button
      await tester.tap(find.text('Modify activity'));
      await tester.pumpAndSettle();

      // Verify that the navigation occurred
      expect(find.byType(NewActivity), findsOneWidget);
    });

    testWidgets('addSlot navigates to new slot page', (
      WidgetTester tester,
    ) async {
      var user = User(uid: 'u1', email: '', isAdmin: true);
      when(mockUserProvider.user).thenReturn(user);
      when(mockInstructorProvider.instructorList).thenReturn([]);
      when(mockGymProvider.gymList).thenReturn([
        Gym(id: 'g1', activities: [Activity(id: 'a1', title: 'Activity 1')]),
      ]);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
            ChangeNotifierProvider<GymProvider>.value(value: mockGymProvider),
            ChangeNotifierProvider<InstructorProvider>.value(
              value: mockInstructorProvider,
            ),
          ],
          child: MaterialApp(home: SlotsPage(gymIndex: 0, activityIndex: 0)),
        ),
      );

      // Tap on the add slot button
      await tester.tap(find.text('Add slot'));
      await tester.pumpAndSettle();

      // Verify that the navigation occurred
      expect(find.byType(NewSlot), findsOneWidget);
    });
  });
}
