import 'package:gymme/content/custom_bottomnavbar.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../provider_test.mocks.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('CustomBottomNavBar Tests', () {
    testWidgets('Bottom navigation bar contains the correct pages', (
      tester,
    ) async {
      final mockUserProvider = MockUserProvider();
      when(mockUserProvider.user).thenReturn(User());
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(
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
        ),
      );

      expect(find.text("Home"), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Bottom navigation bar calls onTapCallback', (tester) async {
      final mockUserProvider = MockUserProvider();
      when(mockUserProvider.user).thenReturn(User());
      var tappedIndex = -1;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(
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
        ),
      );

      await tester.tap(find.byIcon(Icons.search));
      expect(tappedIndex, 1);
    });

    testWidgets('Shows shimmer effect if loading', (tester) async {
      final mockUserProvider = MockUserProvider();
      when(mockUserProvider.user).thenReturn(null);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(
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
        ),
      );

      expect(find.byType(Shimmer), findsOneWidget);
    });
  });
}
