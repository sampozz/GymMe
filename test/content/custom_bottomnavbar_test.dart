import 'package:dima_project/content/custom_bottomnavbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomBottomNavBar Tests', () {
    testWidgets('Bottom navigation bar contains the correct pages', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              pages: [
                {"icon": Icons.home, "title": "Home"},
                {"icon": Icons.search, "title": "Search"},
              ],
              currentIndex: 0,
              onTapCallback: (index) {},
            ),
          ),
        ),
      );

      expect(find.text("Home"), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Bottom navigation bar calls onTapCallback', (tester) async {
      var tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              pages: [
                {"icon": Icons.home, "title": "Home"},
                {"icon": Icons.search, "title": "Search"},
              ],
              currentIndex: 0,
              onTapCallback: (index) {
                tappedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      expect(tappedIndex, 1);
    });
  });
}
