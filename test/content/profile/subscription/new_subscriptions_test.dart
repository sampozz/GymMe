import 'package:dima_project/content/profile/subscription/new_subscription.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late User testUser;

  setUp(() {
    mockUserProvider = MockUserProvider();

    testUser = User(
      uid: 'test-uid',
      displayName: 'Test User',
      email: 'test@example.com',
      photoURL: '',
      certificateExpDate: DateTime(2025, 12, 31),
      isAdmin: false,
      favouriteGyms: [],
      subscriptions: [],
    );
  });

  Widget createTestWidget({User? user}) {
    return ChangeNotifierProvider<UserProvider>.value(
      value: mockUserProvider,
      child: MaterialApp(home: NewSubscription(user: user)),
    );
  }

  group('NewSubscription Widget Tests', () {
    testWidgets(
      'should display user information correctly and tabs for Subscription and Medical Certificate',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(find.text('Test User'), findsOneWidget);
        expect(find.text('test@example.com'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);

        expect(find.text('Subscription'), findsOneWidget);
        expect(find.text('Medical Certificate'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);
      },
    );

    testWidgets(
      'should display subscription form fields duration options (with radio buttons), and save button in first tab',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(find.text('Plan Information'), findsOneWidget);
        expect(find.text('Duration'), findsOneWidget);
        expect(find.text('Payment Details'), findsOneWidget);

        expect(find.text('Title'), findsOneWidget);
        expect(find.byIcon(Icons.title_outlined), findsOneWidget);

        expect(find.text('Description'), findsOneWidget);
        expect(find.byIcon(Icons.description_outlined), findsOneWidget);

        expect(find.text('Price (€)'), findsOneWidget);
        expect(find.byIcon(Icons.euro_symbol_outlined), findsOneWidget);

        expect(find.text('1 month'), findsOneWidget);
        expect(find.text('3 months'), findsOneWidget);
        expect(find.text('6 months'), findsOneWidget);
        expect(find.text('12 months'), findsOneWidget);
        expect(find.byType(RadioListTile<int>), findsNWidgets(4));

        expect(find.text('Save Subscription'), findsOneWidget);
        expect(find.byIcon(Icons.save_outlined), findsOneWidget);
      },
    );

    testWidgets('should select duration correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.scrollUntilVisible(
        find.text('3 months'),
        500.0,
        scrollable: find.byType(Scrollable).first,
      );

      await tester.tap(find.text('3 months'));
      await tester.pump();

      final radioButton = tester.widget<RadioListTile<int>>(
        find.byWidgetPredicate(
          (widget) =>
              widget is RadioListTile<int> &&
              widget.title is Text &&
              (widget.title as Text).data == '3 months',
        ),
      );
      expect(radioButton.value, 3);
    });

    testWidgets('should switch to medical certificate tab', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Medical Certificate'));
      await tester.pumpAndSettle();

      expect(find.text('Medical Certificate Expiry Date'), findsOneWidget);
      expect(find.text('Select date'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
      expect(find.text('Update Medical Certificate'), findsOneWidget);
    });

    testWidgets('should show date picker when select date is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Medical Certificate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select date'));
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should display user certificate expiry date when available', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Medical Certificate'));
      await tester.pumpAndSettle();

      expect(find.text('31/12/2025'), findsOneWidget);
      expect(find.byIcon(Icons.event_available_outlined), findsOneWidget);
    });

    testWidgets(
      'should show "No date selected" when certificate date is null',
      (WidgetTester tester) async {
        final userWithoutCert = User(
          uid: 'test-uid',
          displayName: 'Test User',
          email: 'test@example.com',
          photoURL: '',
          certificateExpDate: null,
          isAdmin: false,
          favouriteGyms: [],
          subscriptions: [],
        );

        await tester.pumpWidget(createTestWidget(user: userWithoutCert));
        await tester.tap(find.text('Medical Certificate'));
        await tester.pumpAndSettle();

        expect(find.text('No date selected'), findsOneWidget);
      },
    );
  });

  group('NewSubscription Form Validation Tests', () {
    testWidgets('should show validation errors for empty subscription fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Save Subscription'));
      await tester.pump();

      expect(find.text('This field is required'), findsNWidgets(3));
    });

    testWidgets('should validate and save subscription with valid data', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.addSubscription(any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Premium Plan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Full access to gym',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Price (€)'),
        '50.00',
      );

      await tester.tap(find.text('Save Subscription'));
      await tester.pump();

      verify(mockUserProvider.addSubscription(any, any)).called(1);
    });

    testWidgets(
      'should show error when trying to save medical cert without date',
      (WidgetTester tester) async {
        final userWithoutCert = User(
          uid: 'test-uid',
          displayName: 'Test User',
          email: 'test@example.com',
          photoURL: '',
          certificateExpDate: null,
          isAdmin: false,
          favouriteGyms: [],
          subscriptions: [],
        );

        await tester.pumpWidget(createTestWidget(user: userWithoutCert));

        await tester.tap(find.text('Medical Certificate'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update Medical Certificate'));
        await tester.pumpAndSettle();

        expect(find.text('Please select an expiry date'), findsOneWidget);
      },
    );
  });

  group('NewSubscription Save Functionality Tests', () {
    testWidgets(
      'should show loading indicator and then success message when saving subscription',
      (WidgetTester tester) async {
        final completer = Completer<void>();
        when(
          mockUserProvider.addSubscription(any, any),
        ).thenAnswer((_) => completer.future);

        await tester.pumpWidget(createTestWidget(user: testUser));

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Title'),
          'Premium Plan',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Description'),
          'Full access',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Price (€)'),
          '50.00',
        );

        await tester.tap(find.text('Save Subscription'));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Saving...'), findsOneWidget);

        completer.complete();
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Saving...'), findsNothing);

        verify(mockUserProvider.addSubscription(any, any)).called(1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('should save medical certificate with selected date', (
      WidgetTester tester,
    ) async {
      when(
        mockUserProvider.updateMedicalCertificate(any, any),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.tap(find.text('Medical Certificate'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Medical Certificate'));
      await tester.pumpAndSettle();

      verify(mockUserProvider.updateMedicalCertificate(any, any)).called(1);
    });

    testWidgets('should show error message on save failure', (
      WidgetTester tester,
    ) async {
      when(
        mockUserProvider.addSubscription(any, any),
      ).thenThrow(Exception('Save failed'));

      await tester.pumpWidget(createTestWidget(user: testUser));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Title'),
        'Premium Plan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Full access',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Price (€)'),
        '50.00',
      );

      await tester.tap(find.text('Save Subscription'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('There\'s been an issue during the update'),
        findsOneWidget,
      );
    });
  });

  group('NewSubscription UI Interaction Tests', () {
    testWidgets('should display correct app bar title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.text('User documents'), findsOneWidget);
    });

    testWidgets('should handle user with no photo gracefully', (
      WidgetTester tester,
    ) async {
      final userWithoutPhoto = User(
        uid: 'test-uid',
        displayName: 'Test User',
        email: 'test@example.com',
        photoURL: '',
        isAdmin: false,
        favouriteGyms: [],
        subscriptions: [],
      );

      await tester.pumpWidget(createTestWidget(user: userWithoutPhoto));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'should display payment info text and medical certificate info text correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(user: testUser));

        expect(
          find.text('Full payment required at the time of subscription.'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.info_outline), findsOneWidget);

        await tester.tap(find.text('Medical Certificate'));
        await tester.pumpAndSettle();

        expect(
          find.text(
            'The medical certificate must be valid to participate in gym activities.',
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('should show different button icons for different tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(user: testUser));

      expect(find.byIcon(Icons.save_outlined), findsOneWidget);

      await tester.tap(find.text('Medical Certificate'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.medical_services_outlined), findsOneWidget);
    });
  });
}
