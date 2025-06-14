import 'package:dima_project/content/profile/my_data.dart';
import 'package:dima_project/content/profile/profile_page.dart';
import 'package:dima_project/content/profile/subscription/subscriptions.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/theme_provider.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late MockThemeProvider mockThemeProvider;
  late User testUser;

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockThemeProvider = MockThemeProvider();

    testUser = User(
      uid: 'test-uid',
      displayName: 'Test User',
      email: 'test@example.com',
      photoURL: '',
      phoneNumber: '+1234567890',
      address: '123 Test St',
      taxCode: 'TEST123',
      birthPlace: 'Test City',
      birthDate: DateTime(1990, 1, 1),
      isAdmin: false,
      certificateExpDate: DateTime.now().add(Duration(days: 30)),
      favouriteGyms: [],
      subscriptions: [],
    );

    when(mockThemeProvider.currentThemeMode).thenReturn('Auto');
    when(mockThemeProvider.cycleTheme()).thenAnswer((_) async {});
  });

  Widget createTestWidget({User? user}) {
    when(mockUserProvider.user).thenReturn(user);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: mockThemeProvider),
      ],
      child: MaterialApp(home: Scaffold(body: ProfilePage())),
    );
  }

  group('ProfilePage Widget Tests', () {
    testWidgets('should show loading indicator when user is null', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.user).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display user profile card with user information', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should display medical certificate info for non-admin users', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.text('Medical certificate exp:'), findsOneWidget);
      expect(find.textContaining('/'), findsOneWidget);
    });

    testWidgets(
      'should display theme toggle button with correct mode and cycle theme when is pressed',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(find.text('Auto'), findsOneWidget);
        expect(find.byIcon(Icons.brightness_auto_outlined), findsOneWidget);

        await tester.tap(find.byIcon(Icons.brightness_auto_outlined));
        await tester.pump();

        verify(mockThemeProvider.cycleTheme()).called(1);
      },
    );

    testWidgets('should display and navigate to My Data navigation tile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.text('My data'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios_outlined), findsWidgets);

      await tester.tap(find.text('My data'));
      await tester.pumpAndSettle();

      expect(find.byType(MyData), findsOneWidget);
    });

    testWidgets(
      'should display and navigate to Subscriptions for non-admin users',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(find.text('Subscriptions'), findsOneWidget);

        await tester.tap(find.text('Subscriptions'));
        await tester.pumpAndSettle();

        expect(find.byType(Subscriptions), findsOneWidget);
      },
    );

    testWidgets('should display Logout navigation tile', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout_outlined), findsOneWidget);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Confirm logout'), findsOneWidget);
    });

    testWidgets('should display Delete account option', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.text('Delete account'), findsOneWidget);

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      expect(
        find.text('Are you sure you want to cancel the account?'),
        findsOneWidget,
      );
      expect(find.text('Confirm deletion'), findsOneWidget);
    });

    testWidgets('should call signOut when logout is confirmed', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.signOut()).thenAnswer((_) async {});
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm logout'));
      await tester.pump();

      verify(mockUserProvider.signOut()).called(1);
    });

    testWidgets('should call deleteAccount when deletion is confirmed', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.deleteAccount(any)).thenAnswer((_) async {});
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm deletion'));
      await tester.pump();

      verify(mockUserProvider.deleteAccount('test-uid')).called(1);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show green indicator for valid medical certificate', (
      WidgetTester tester,
    ) async {
      final userWithValidCert = User(
        uid: testUser.uid,
        displayName: testUser.displayName,
        email: testUser.email,
        photoURL: testUser.photoURL,
        phoneNumber: testUser.phoneNumber,
        address: testUser.address,
        taxCode: testUser.taxCode,
        birthPlace: testUser.birthPlace,
        birthDate: testUser.birthDate,
        isAdmin: testUser.isAdmin,
        certificateExpDate: DateTime.now().add(Duration(days: 30)),
        favouriteGyms: testUser.favouriteGyms,
        subscriptions: testUser.subscriptions,
      );
      when(mockUserProvider.user).thenReturn(userWithValidCert);

      await tester.pumpWidget(createTestWidget(user: userWithValidCert));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.green,
        ),
      );
      expect(container, isNotNull);
    });

    testWidgets('should show red indicator for expired medical certificate', (
      WidgetTester tester,
    ) async {
      final userWithExpiredCert = User(
        uid: testUser.uid,
        displayName: testUser.displayName,
        email: testUser.email,
        photoURL: testUser.photoURL,
        phoneNumber: testUser.phoneNumber,
        address: testUser.address,
        taxCode: testUser.taxCode,
        birthPlace: testUser.birthPlace,
        birthDate: testUser.birthDate,
        isAdmin: testUser.isAdmin,
        certificateExpDate: DateTime.now().subtract(Duration(days: 30)),
        favouriteGyms: testUser.favouriteGyms,
        subscriptions: testUser.subscriptions,
      );
      when(mockUserProvider.user).thenReturn(userWithExpiredCert);

      await tester.pumpWidget(createTestWidget(user: userWithExpiredCert));

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).color == Colors.red,
        ),
      );
      expect(container, isNotNull);
    });
  });

  group('Theme Toggle Button Tests', () {
    testWidgets('should display correct icon for Auto theme', (
      WidgetTester tester,
    ) async {
      when(mockThemeProvider.currentThemeMode).thenReturn('Auto');

      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byIcon(Icons.brightness_auto_outlined), findsOneWidget);
      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('should display correct icon for Light theme', (
      WidgetTester tester,
    ) async {
      when(mockThemeProvider.currentThemeMode).thenReturn('Light');

      await tester.pumpWidget(createTestWidget(user: testUser));
      await tester.pump();

      expect(find.byIcon(Icons.wb_sunny_outlined), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('should display correct icon for Dark theme', (
      WidgetTester tester,
    ) async {
      when(mockThemeProvider.currentThemeMode).thenReturn('Dark');

      await tester.pumpWidget(createTestWidget(user: testUser));
      await tester.pump();

      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });
  });

  group('UI Responsive Tests', () {
    testWidgets('should display user avatar correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      final circleAvatar = find.byType(CircleAvatar);
      expect(circleAvatar, findsOneWidget);

      final avatar = tester.widget<CircleAvatar>(circleAvatar);
      expect(avatar.radius, 50);
    });
  });
}
