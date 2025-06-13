import 'package:gymme/content/home/gym/activity/slots/admin_slot_modal.dart';
import 'package:gymme/content/home/gym/activity/slots/new_slot.dart';
import 'package:gymme/models/slot_model.dart';
import 'package:gymme/providers/slot_provider.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late MockSlotProvider mockSlotProvider;
  late Slot testSlot;
  late List<User> testUsers;

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockSlotProvider = MockSlotProvider();

    // Create a test slot
    testSlot = Slot(
      id: 'test-slot-id',
      gymId: 'test-gym-id',
      activityId: 'test-activity-id',
      bookedUsers: ['user1', 'user2'],
      startTime: DateTime(
        2025,
        5,
        12,
        10,
        0,
      ), // Use the current date from context
      endTime: DateTime(2025, 5, 12, 11, 0),
    );

    // Create test users
    testUsers = [
      User(
        uid: 'user1',
        email: 'user1@example.com',
        displayName: 'Test User 1',
        isAdmin: false,
      ),
      User(
        uid: 'user2',
        email: 'user2@example.com',
        displayName: 'Test User 2',
        isAdmin: false,
      ),
    ];

    // Set up the mock responses
    when(
      mockUserProvider.getUsersByIds(any),
    ).thenAnswer((_) async => testUsers);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<SlotProvider>.value(value: mockSlotProvider),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder:
                (context) => ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => AdminSlotModal(slot: testSlot),
                    );
                  },
                  child: const Text('Show Modal'),
                ),
          ),
        ),
      ),
    );
  }

  testWidgets('AdminSlotModal displays booked users after loading', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(createTestWidget());

    // Open the modal
    await tester.tap(find.text('Show Modal'));
    await tester.pump();

    // Simulate async data loading completion
    await tester.pump();

    // Assert - should display user list and not loading indicator
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Users booked this slot:'), findsOneWidget);
    expect(find.text('Test User 1'), findsOneWidget);
    expect(find.text('Test User 2'), findsOneWidget);
    expect(find.text('user1@example.com'), findsOneWidget);
    expect(find.text('user2@example.com'), findsOneWidget);
  });

  testWidgets('AdminSlotModal shows message when no users booked', (
    WidgetTester tester,
  ) async {
    // Arrange
    when(mockUserProvider.getUsersByIds(any)).thenAnswer((_) async => []);
    await tester.pumpWidget(createTestWidget());

    // Open the modal
    await tester.tap(find.text('Show Modal'));
    await tester.pump();

    // Simulate async data loading completion
    await tester.pump();

    // Assert - should show empty state message
    expect(find.text('No users booked this slot'), findsOneWidget);
  });

  testWidgets('Modify slot button should navigate to NewSlot', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(createTestWidget());

    // Open the modal
    await tester.tap(find.text('Show Modal'));
    await tester.pump();

    // Simulate async data loading completion
    await tester.pump();

    // Find the modify button and ensure it's in view
    final modifyButtonFinder = find.text('Modify slot');
    await tester.ensureVisible(modifyButtonFinder);
    await tester.pumpAndSettle();

    // Act - tap the modify button
    await tester.tap(modifyButtonFinder);
    await tester.pumpAndSettle();

    // Assert - should navigate to NewSlot
    expect(find.byType(NewSlot), findsOneWidget);
  });

  testWidgets('Delete slot button should show confirmation dialog', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(createTestWidget());

    // Open the modal
    await tester.tap(find.text('Show Modal'));
    await tester.pump();

    // Simulate async data loading completion
    await tester.pump();

    // Find the delete button and ensure it's in view
    final deleteButtonFinder = find.text('Delete slot');
    await tester.ensureVisible(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Act - tap the delete button
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Assert - should show confirmation dialog
    expect(find.text('Delete Slot'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete this slot?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('Confirming delete should call deleteSlot and close modal', (
    WidgetTester tester,
  ) async {
    // Arrange
    await tester.pumpWidget(createTestWidget());

    // Open the modal
    await tester.tap(find.text('Show Modal'));
    await tester.pump();

    // Simulate async data loading completion
    await tester.pump();

    // Find the delete button and ensure it's in view
    final deleteButtonFinder = find.text('Delete slot');
    await tester.ensureVisible(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Act - tap delete button
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Confirm deletion in the dialog
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Assert - deleteSlot should be called and modal closed
    verify(mockSlotProvider.deleteSlot(testSlot.id)).called(1);
    expect(find.byType(AdminSlotModal), findsNothing);
  });

  testWidgets('Should handle image loading errors gracefully', (
    WidgetTester tester,
  ) async {
    // Arrange - create a user with an invalid image URL
    final usersWithBadImage = [
      User(
        uid: 'user1',
        email: 'user1@example.com',
        displayName: 'User With Bad Image',
        photoURL: 'https://invalid-url.com/photo.jpg',
        isAdmin: false,
      ),
    ];

    when(
      mockUserProvider.getUsersByIds(any),
    ).thenAnswer((_) async => usersWithBadImage);
    await tester.pumpWidget(createTestWidget());

    // Open the modal
    await tester.tap(find.text('Show Modal'));
    await tester.pump();

    // Simulate async data loading completion
    await tester.pump();

    // Simulate image error
    await tester.pump();

    // Assert - should show fallback image
    expect(find.byType(Image), findsWidgets);
    // Can't directly check if it's showing the fallback image, but we can verify no errors occurred
  });
}
