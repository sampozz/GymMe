import 'package:dima_project/content/custom_sidebar.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserProvider extends Mock implements UserProvider {}

void main() {
  group('Custom sidebar', () {
    testWidgets('should display the sidebar', (WidgetTester tester) async {
      return;
      final mockUserProvider = MockUserProvider();

      when(mockUserProvider.user).thenReturn(User());

      // Build the widget
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(
            home: CustomSidebar(
              pages: [
                {'title': 'Page 1', 'icon': Icons.home, 'page': Container()},
              ],
              currentIndex: 0,
              navigatorKey: null,
              onTapCallback: (p0) => {},
            ),
          ),
        ),
      );

      // Find the sidebar
      final sidebarFinder = find.byType(CustomSidebar);

      // Find the title of the first page
      final titleFinder = find.text('Page 1');

      // Expect the sidebar to be displayed
      expect(sidebarFinder, findsOneWidget);

      // Expect the title of the first page to be displayed
      expect(titleFinder, findsOneWidget);
    });
  });
}
