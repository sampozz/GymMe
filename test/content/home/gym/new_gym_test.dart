import 'package:dima_project/content/home/gym/new_gym.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NewGym page', () {
    testWidgets('should diplay a form', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(MaterialApp(home: NewGym()));

      // Verify that the form is displayed
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
