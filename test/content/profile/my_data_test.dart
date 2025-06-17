import 'package:gymme/content/profile/my_data.dart';
import 'package:gymme/content/profile/new_my_data.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late User testUser;
  late User testAdminUser;

  setUp(() {
    mockUserProvider = MockUserProvider();

    testUser = User(
      uid: 'test-uid',
      displayName: 'Test User',
      email: 'test@example.com',
      photoURL: 'https://example.com/photo.jpg',
      phoneNumber: '+1234567890',
      address: '123 Test St',
      taxCode: 'TEST123',
      birthPlace: 'Test City',
      birthDate: DateTime(1990, 1, 1),
      isAdmin: false,
      favouriteGyms: [],
      subscriptions: [],
    );

    testAdminUser = User(
      uid: 'admin-uid',
      displayName: 'Admin User',
      email: 'admin@example.com',
      photoURL: '',
      isAdmin: true,
      favouriteGyms: [],
      subscriptions: [],
    );
  });

  Widget createTestWidget({User? user}) {
    // Reset e riconfigura il mock ad ogni chiamata
    reset(mockUserProvider);
    when(mockUserProvider.user).thenReturn(user);
    when(mockUserProvider.hasListeners).thenReturn(false);
    when(mockUserProvider.addListener(any)).thenAnswer((_) {});
    when(mockUserProvider.removeListener(any)).thenAnswer((_) {});

    return ChangeNotifierProvider<UserProvider>.value(
      value: mockUserProvider,
      child: MaterialApp(home: MyData()),
    );
  }

  group('MyData Widget Tests', () {
    testWidgets('should show loading indicator when user is null', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.user).thenReturn(null);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display user data correctly for regular user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));
      await tester.pumpAndSettle();

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('123 Test St'), findsOneWidget);
      expect(find.text('TEST123'), findsOneWidget);
      expect(find.text('1/1/1990'), findsOneWidget);
    });

    testWidgets('should display admin data correctly (no extra fields)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testAdminUser));

      expect(find.text('Admin User'), findsOneWidget);
      expect(find.text('admin@example.com'), findsOneWidget);

      expect(find.text('Phone number'), findsNothing);
      expect(find.text('Address'), findsNothing);
      expect(find.text('Tax code'), findsNothing);
      expect(find.text('Birth date'), findsNothing);
      expect(find.text('Birth place'), findsNothing);
    });

    testWidgets('should show "Unspecified" for empty fields', (
      WidgetTester tester,
    ) async {
      final userWithEmptyFields = User(
        uid: testUser.uid,
        displayName: '',
        email: testUser.email,
        photoURL: testUser.photoURL,
        phoneNumber: '',
        address: '',
        taxCode: '',
        birthPlace: '',
        birthDate: null,
        isAdmin: false,
        favouriteGyms: [],
        subscriptions: [],
      );

      await tester.pumpWidget(createTestWidget(user: userWithEmptyFields));

      expect(find.text('Unspecified'), findsNWidgets(5));
    });

    testWidgets('should display profile picture for regular user', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets(
      'should show modify button for regular user and navigate to NewMyData when pressed',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(find.text('Modify'), findsOneWidget);
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);

        await tester.tap(find.text('Modify'));
        await tester.pumpAndSettle();

        expect(find.byType(NewMyData), findsOneWidget);
      },
    );

    testWidgets('should display all required icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });
  });

  group('Responsive Layout Tests', () {
    testWidgets('should use mobile layout on small screen', (
      WidgetTester tester,
    ) async {
      tester.binding.window.physicalSizeTestValue = Size(350, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(createTestWidget(user: testUser));

      // Verifies presence of Column (mobile layout)
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should use desktop layout on large screen', (
      WidgetTester tester,
    ) async {
      tester.binding.window.physicalSizeTestValue = Size(1200, 800);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
      addTearDown(tester.binding.window.clearDevicePixelRatioTestValue);

      await tester.pumpWidget(createTestWidget(user: testUser));

      // Verifies presence of Row (desktop layout)
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('Data Display Tests', () {
    testWidgets('should format birth date correctly', (
      WidgetTester tester,
    ) async {
      final userWithSpecificDate = User(
        uid: testUser.uid,
        displayName: testUser.displayName,
        email: testUser.email,
        photoURL: testUser.photoURL,
        phoneNumber: testUser.phoneNumber,
        address: testUser.address,
        taxCode: testUser.taxCode,
        birthPlace: testUser.birthPlace,
        birthDate: DateTime(1995, 12, 25),
        isAdmin: testUser.isAdmin,
        favouriteGyms: testUser.favouriteGyms,
        subscriptions: testUser.subscriptions,
      );

      await tester.pumpWidget(createTestWidget(user: userWithSpecificDate));

      expect(find.text('25/12/1995'), findsOneWidget);
    });

    testWidgets('should display all list tiles with correct structure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byType(ListTile), findsNWidgets(6));
    });
  });
}
