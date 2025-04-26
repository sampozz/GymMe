import 'package:dima_project/content/custom_sidebar.dart';
import 'package:dima_project/content/home/home.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../provider_test.mocks.dart';

void main() {
  group('Custom sidebar', () {
    testWidgets('should display the sidebar', (WidgetTester tester) async {
      final user = User(email: 'mail');
      final mockUserProvider = MockUserProvider();
      when(mockUserProvider.user).thenReturn(user);
      when(mockUserProvider.signIn('any', 'any')).thenAnswer((_) async => user);

      final pages = [
        {
          "title": "Home",
          "description": "Home page",
          "icon": Icons.home_outlined,
          "widget": Home(),
        },
      ];

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
          ],
          child: MaterialApp(
            home: CustomSidebar(
              pages: pages,
              currentIndex: 0,
              onTapCallback: (index) {},
            ),
          ),
        ),
      );

      expect(find.byType(CustomSidebar), findsOneWidget);
    });
  });
}
