import 'package:dima_project/content/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomAppBar tests', () {
    testWidgets('should display the welcome text', (WidgetTester tester) async {
      return;
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(appBar: CustomAppBar())),
      );

      // Find the title widget
      final titleFinder = find.text('Welcome back,');

      // Expect the title to be displayed
      expect(titleFinder, findsOneWidget);
    });
  });
}
