import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymme/models/gym_model.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/content/home/gym/new_gym.dart'; // Update with correct import path
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';

// Generate mock classes
import '../../../provider_test.mocks.dart';

void main() {
  late MockGymProvider mockGymProvider;

  setUp(() {
    mockGymProvider = MockGymProvider();
    // Setup default behavior
    when(
      mockGymProvider.uploadImage(any),
    ).thenAnswer((_) async => 'mock-image-url');
    when(mockGymProvider.addGym(any)).thenAnswer((_) async => true);
    when(mockGymProvider.updateGym(any)).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest({Gym? gym}) {
    return MaterialApp(
      home: ChangeNotifierProvider<GymProvider>.value(
        value: mockGymProvider,
        child: NewGym(gym: gym),
      ),
    );
  }

  group('NewGym Widget Tests', () {
    testWidgets('Form validation works - empty name and address shows errors', (
      WidgetTester tester,
    ) async {
      // Set a larger size for the test viewport to ensure buttons are visible
      tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(createWidgetUnderTest());

      // Find the form key
      final formState = tester.state<FormState>(find.byType(Form));

      // Clear the text fields (they might have default values)
      await tester.enterText(
        find.byType(TextFormField).at(0),
        '',
      ); // Name field
      await tester.enterText(
        find.byType(TextFormField).at(2),
        '',
      ); // Address field

      // Find the submit button first before trying to tap it
      final submitButton = find.text('Add Gym');
      expect(submitButton, findsOneWidget);

      // Use ensureVisible to make sure the button is in view
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      // Tap the submit button
      await tester.tap(submitButton);
      await tester.pump();

      // Validate the form directly to ensure errors appear
      expect(formState.validate(), isFalse);
      await tester.pump(); // Pump again to show validation errors

      // Find the validation text directly in the widget tree
      expect(find.text('This field is required'), findsWidgets);
    });

    testWidgets('Adding a new gym works correctly', (
      WidgetTester tester,
    ) async {
      // Set a larger size for the test viewport to ensure buttons are visible
      tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(createWidgetUnderTest());

      // Fill in form data
      await tester.enterText(find.byType(TextFormField).at(0), 'Test Gym');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Test Description',
      );
      await tester.enterText(find.byType(TextFormField).at(2), '123 Test St.');
      await tester.enterText(find.byType(TextFormField).at(3), '555-1234');

      // Set time values directly instead of using the picker
      final openTimeField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(4),
      );
      openTimeField.controller!.text = '09:00';

      final closeTimeField = tester.widget<TextFormField>(
        find.byType(TextFormField).at(5),
      );
      closeTimeField.controller!.text = '18:00';

      // Find submit button and ensure it's visible
      final submitButton = find.text('Add Gym');
      await tester.ensureVisible(submitButton);
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify that addGym was called
      verify(mockGymProvider.addGym(any)).called(1);
    });

    testWidgets('Editing an existing gym works correctly', (
      WidgetTester tester,
    ) async {
      // Set a larger size for the test viewport
      tester.binding.window.physicalSizeTestValue = Size(1080, 1920);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      // Create a sample gym
      final testGym = Gym(
        name: 'Original Gym',
        description: 'Original Description',
        address: 'Original Address',
        phone: '555-5555',
        imageUrl: 'http://example.com/image.jpg',
        openTime: DateTime(1985, 5, 12, 9, 0),
        closeTime: DateTime(1985, 5, 12, 17, 0),
        activities: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(gym: testGym));

      // Verify initial values are loaded
      expect(find.text('Original Gym'), findsOneWidget);
      expect(find.text('Original Description'), findsOneWidget);
      expect(find.text('Original Address'), findsOneWidget);
      expect(find.text('555-5555'), findsOneWidget);

      // Modify form data
      await tester.enterText(find.byType(TextFormField).at(0), 'Updated Gym');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Updated Address',
      );

      // Find submit button and ensure it's visible
      final updateButton = find.text('Update Gym');
      await tester.ensureVisible(updateButton);
      await tester.pumpAndSettle();

      // Submit the form
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Verify that updateGym was called
      verify(mockGymProvider.updateGym(any)).called(1);
    });

    testWidgets('App bar has correct title for new gym', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Add gym'), findsOneWidget);
    });

    testWidgets('App bar has correct title for edit gym', (
      WidgetTester tester,
    ) async {
      final testGym = Gym(
        name: 'Test Gym',
        description: 'Test Description',
        address: 'Test Address',
        phone: '555-5555',
        imageUrl: '',
        openTime: DateTime(1985, 5, 12, 9, 0),
        closeTime: DateTime(1985, 5, 12, 17, 0),
        activities: [],
      );

      await tester.pumpWidget(createWidgetUnderTest(gym: testGym));
      expect(find.text('Edit gym'), findsOneWidget);
    });

    testWidgets('should show time picker on tap', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Tap the open time field
      await tester.tap(find.byType(TextFormField).at(4));
      await tester.pumpAndSettle();

      // Verify that the time picker is displayed
      expect(find.byType(TimePickerDialog), findsOneWidget);

      // Simulate selecting a time
      await tester.tap(find.text('OK').last);
      await tester.pumpAndSettle();
    });
  });
}
