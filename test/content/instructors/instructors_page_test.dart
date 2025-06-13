import 'package:gymme/models/instructor_model.dart';
import 'package:gymme/providers/instructor_provider.dart';
import 'package:gymme/content/home/gym/activity/instructors/instructors_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  group('InstructorsPage', () {
    testWidgets('renders instructor list', (WidgetTester tester) async {
      // Mock the InstructorProvider and its methods
      final instructorProvider = MockInstructorProvider();
      when(instructorProvider.instructorList).thenReturn([
        Instructor(
          id: '1',
          name: 'John Doe',
          title: 'Yoga Instructor',
          photo: 'https://example.com/photo.jpg',
        ),
      ]);

      // Build the InstructorsPage widget
      await tester.pumpWidget(
        ChangeNotifierProvider<InstructorProvider>.value(
          value: instructorProvider,
          child: MaterialApp(home: InstructorsPage()),
        ),
      );

      // Verify that the instructor list is displayed
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Yoga Instructor'), findsOneWidget);
    });

    testWidgets('tap shows create instructor form', (tester) async {
      // Mock the InstructorProvider and its methods
      final instructorProvider = MockInstructorProvider();
      when(instructorProvider.instructorList).thenReturn([]);

      // Build the InstructorsPage widget
      await tester.pumpWidget(
        ChangeNotifierProvider<InstructorProvider>.value(
          value: instructorProvider,
          child: MaterialApp(home: InstructorsPage()),
        ),
      );

      // Tap the add button to show the create instructor form
      await tester.tap(find.text('New Instructor'));
      await tester.pumpAndSettle();

      // Verify that the create instructor form is displayed
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('create instructor calls addInstructor', (tester) async {
      // Mock the InstructorProvider and its methods
      final instructorProvider = MockInstructorProvider();
      when(instructorProvider.instructorList).thenReturn([]);

      // Build the InstructorsPage widget
      await tester.pumpWidget(
        ChangeNotifierProvider<InstructorProvider>.value(
          value: instructorProvider,
          child: MaterialApp(home: InstructorsPage()),
        ),
      );

      // Tap the add button to show the create instructor form
      await tester.tap(find.text('New Instructor'));
      await tester.pumpAndSettle();

      // Fill in the form fields
      await tester.enterText(find.byKey(const Key('nameCtrl')), 'John Doe');

      // Tap the save button
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      // Verify that addInstructor was called with the correct parameters
      verify(instructorProvider.addInstructor(any)).called(1);
    });
  });
}
