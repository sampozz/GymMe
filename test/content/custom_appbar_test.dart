import 'package:dima_project/content/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomAppBar tests', () {
    testWidgets('should display the title', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: CustomAppBar(title: 'Test'))),
      );

      // Find the title widget
      final titleFinder = find.text('Test');

      // Expect the title to be displayed
      expect(titleFinder, findsOneWidget);
    });
  });
}
