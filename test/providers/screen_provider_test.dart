import 'package:dima_project/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScreenProvider', () {
    testWidgets('should return screen size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('Hello World'))),
        ),
      );

      final screenData = MediaQuery.of(
        tester.element(find.text('Hello World')),
      );

      final screenProvider = ScreenProvider();
      screenProvider.screenData = screenData;
      expect(screenProvider.screenData, screenData);

      expect(screenProvider.useMobileLayout, false);
    });
  });
}
