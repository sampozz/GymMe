import 'package:dima_project/content/instructors/instructor_model.dart';
import 'package:dima_project/content/instructors/instructor_provider.dart';
import 'package:dima_project/content/instructors/instructors_page.dart';
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
  });
}
