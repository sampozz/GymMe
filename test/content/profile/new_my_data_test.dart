import 'package:dima_project/content/profile/new_my_data.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late User testUser;

  setUp(() {
    mockUserProvider = MockUserProvider();

    when(
      mockUserProvider.updateUserProfile(
        displayName: anyNamed('displayName'),
        photoURL: anyNamed('photoURL'),
        phoneNumber: anyNamed('phoneNumber'),
        address: anyNamed('address'),
        taxCode: anyNamed('taxCode'),
        birthPlace: anyNamed('birthPlace'),
        birthDate: anyNamed('birthDate'),
      ),
    ).thenAnswer((_) async => Future.value());

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
  });

  Widget createTestWidget({User? user}) {
    return ChangeNotifierProvider<UserProvider>.value(
      value: mockUserProvider,
      child: MaterialApp(home: NewMyData(user: user)),
    );
  }

  group('NewMyData Widget Tests', () {
    testWidgets(
      'should display all form fields and pre-populate them with existing user data',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(find.text('Name and Surname'), findsOneWidget);
        expect(find.text('Phone number'), findsOneWidget);
        expect(find.text('Address'), findsOneWidget);
        expect(find.text('Tax code'), findsOneWidget);
        expect(find.text('Birth date'), findsOneWidget);
        expect(find.text('Birth place'), findsOneWidget);
        expect(find.text('Save changes'), findsOneWidget);

        // Check if the fields are pre-populated with the test user data
        expect(find.text('Test User'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.text('+1234567890'), findsOneWidget);
        expect(find.text('123 Test St'), findsOneWidget);
        expect(find.text('TEST123'), findsOneWidget);
        expect(find.text('Test City'), findsOneWidget);
        expect(find.text('1/1/1990'), findsOneWidget);
      },
    );

    testWidgets('should display profile picture with edit overlay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should show email field as disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      final emailField = tester.widget<TextFormField>(
        find.byWidgetPredicate(
          (widget) => widget is TextFormField && widget.enabled == false,
        ),
      );
      expect(emailField.enabled, false);
    });

    testWidgets('should display form with empty fields when user is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: null));

      expect(find.byType(TextFormField), findsNWidgets(7));
    });

    testWidgets('should display correct icons for each field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byIcon(Icons.person_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.save_outlined), findsOneWidget);
    });
  });

  group('Form Validation Tests', () {
    testWidgets('should show validation errors for mandatory fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      final nameField = find.widgetWithText(TextFormField, 'Test User');
      final phoneField = find.widgetWithText(TextFormField, '+1234567890');

      await tester.enterText(nameField, '');
      await tester.enterText(phoneField, '');

      await tester.tap(find.text('Save changes'));
      await tester.pump();

      expect(find.text('This field is required'), findsAtLeastNWidgets(1));
    });

    testWidgets('should validate form before saving', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      final nameField = find.widgetWithText(TextFormField, 'Test User');
      await tester.enterText(nameField, 'Updated Name');

      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      verify(
        mockUserProvider.updateUserProfile(
          displayName: 'Updated Name',
          photoURL: anyNamed('photoURL'),
          phoneNumber: anyNamed('phoneNumber'),
          address: anyNamed('address'),
          taxCode: anyNamed('taxCode'),
          birthPlace: anyNamed('birthPlace'),
          birthDate: anyNamed('birthDate'),
        ),
      ).called(1);
    });
  });

  group('Date Picker Tests', () {
    testWidgets('should handle birth date field interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.dragUntilVisible(
        find.text('Birth date'),
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();

      final birthDateField = find.text('Birth date');

      expect(birthDateField, findsOneWidget);

      await tester.tap(birthDateField, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(CalendarDatePicker), findsOneWidget);
    });
  });

  group('Save Functionality Tests', () {
    testWidgets(
      'should save user data when valid and show loading indicator while saving',
      (WidgetTester tester) async {
        when(
          mockUserProvider.updateUserProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
            phoneNumber: anyNamed('phoneNumber'),
            address: anyNamed('address'),
            taxCode: anyNamed('taxCode'),
            birthPlace: anyNamed('birthPlace'),
            birthDate: anyNamed('birthDate'),
          ),
        ).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return;
        });

        await tester.pumpWidget(createTestWidget(user: testUser));

        final nameField = find.widgetWithText(TextFormField, 'Test User');
        await tester.enterText(nameField, 'New Name');

        final saveButton = find.text('Save changes');
        expect(saveButton, findsOneWidget);

        await tester.tap(saveButton);
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);

        verify(
          mockUserProvider.updateUserProfile(
            displayName: anyNamed('displayName'),
            photoURL: anyNamed('photoURL'),
            phoneNumber: anyNamed('phoneNumber'),
            address: anyNamed('address'),
            taxCode: anyNamed('taxCode'),
            birthPlace: anyNamed('birthPlace'),
            birthDate: anyNamed('birthDate'),
          ),
        ).called(1);
      },
    );
  });

  group('UI Interaction Tests', () {
    testWidgets('should have profile picture with edit functionality', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byType(CircleAvatar), findsOneWidget);

      expect(find.byIcon(Icons.edit), findsOneWidget);

      expect(
        find.byWidgetPredicate((widget) => widget is GestureDetector),
        findsAtLeastNWidgets(1),
      );
    });
  });
}
