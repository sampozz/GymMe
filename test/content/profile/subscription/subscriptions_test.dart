import 'package:dima_project/content/profile/subscription/subscriptions.dart';
import 'package:dima_project/models/subscription_model.dart';
import 'package:dima_project/models/user_model.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late User testUser;
  late List<Subscription> testSubscriptions;

  setUp(() {
    mockUserProvider = MockUserProvider();

    when(mockUserProvider.hasListeners).thenReturn(false);
    when(mockUserProvider.addListener(any)).thenAnswer((_) {});
    when(mockUserProvider.removeListener(any)).thenAnswer((_) {});

    final now = DateTime.now();
    final futureDate = now.add(Duration(days: 365)); // Valid 1 year from now
    final pastDate = now.subtract(Duration(days: 30)); // Expired 30 days ago
    final nearFutureDate = now.add(Duration(days: 15)); // Valid for 15 days

    testSubscriptions = [
      Subscription(
        id: 'sub1',
        title: 'Premium Plan',
        description: 'Full access to all gym facilities',
        startTime: now,
        paymentDate: now,
        expiryDate: futureDate,
        price: 500.0,
        duration: 12,
      ),
      Subscription(
        id: 'sub2',
        title: 'Basic Plan',
        description: 'Limited access to gym',
        startTime: DateTime(2023, 1, 1),
        paymentDate: DateTime(2023, 1, 1),
        expiryDate: pastDate,
        price: 300.0,
        duration: 12,
      ),
      Subscription(
        id: 'sub3',
        title: 'Monthly Plan',
        description: 'One month access',
        startTime: now.subtract(Duration(days: 15)),
        paymentDate: now.subtract(Duration(days: 15)),
        expiryDate: nearFutureDate,
        price: 50.0,
        duration: 1,
      ),
    ];

    testUser = User(
      uid: 'test-uid',
      displayName: 'Test User',
      email: 'test@example.com',
      subscriptions: testSubscriptions,
      isAdmin: false,
      favouriteGyms: [],
    );
  });

  Widget createTestWidget() {
    when(mockUserProvider.user).thenReturn(testUser);
    return ChangeNotifierProvider<UserProvider>.value(
      value: mockUserProvider,
      child: MaterialApp(home: Subscriptions()),
    );
  }

  group('Subscriptions Widget Tests', () {
    testWidgets('should display app bar with correct title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Subscriptions'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display tabs for Valid and Expired subscriptions', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Valid'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);
    });

    testWidgets(
      'should display valid subscriptions in Valid tab and expired ones in Expired tab',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('PREMIUM PLAN'), findsOneWidget);
        expect(find.text('MONTHLY PLAN'), findsOneWidget);
        expect(
          find.text('BASIC PLAN'),
          findsNothing,
        ); // Should be in expired tab

        await tester.tap(find.text('Expired'));
        await tester.pumpAndSettle();

        expect(find.text('BASIC PLAN'), findsOneWidget);
        expect(
          find.text('PREMIUM PLAN'),
          findsNothing,
        ); // Should be in valid tab
        expect(
          find.text('MONTHLY PLAN'),
          findsNothing,
        ); // Should be in valid tab
      },
    );

    testWidgets(
      'should show green indicator for valid subscriptions and red for expired ones (and the relative icons)',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        final greenCircles = find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.circle &&
              widget.color == Colors.green,
        );
        expect(greenCircles, findsNWidgets(2)); // 2 valid subscriptions
        expect(find.byIcon(Icons.fitness_center), findsNWidgets(2));

        await tester.tap(find.text('Expired'));
        await tester.pumpAndSettle();

        final redCircles = find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.circle &&
              widget.color == Colors.red,
        );
        expect(redCircles, findsOneWidget); // 1 expired subscription
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      },
    );

    testWidgets('should display correct expiry dates', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.textContaining('Expiring on'), findsWidgets);

      final now = DateTime.now();
      final futureDate = now.add(Duration(days: 365));
      final expectedDateString =
          '${futureDate.day.toString().padLeft(2, '0')}/${futureDate.month.toString().padLeft(2, '0')}/${futureDate.year}';
      expect(find.textContaining(expectedDateString), findsOneWidget);
    });

    testWidgets(
      'should expand subscription details when tapped and collapse when tapped again',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Show details'), findsNWidgets(2));
        expect(find.text('Hide details'), findsNothing);
        expect(find.text('Description'), findsNWidgets(2));

        await tester.tap(find.text('Show details').first);
        await tester.pumpAndSettle();

        expect(find.text('Hide details'), findsOneWidget);
        expect(find.text('Show details'), findsNothing);
        expect(find.text('Description'), findsOneWidget);
        expect(find.text('Start date'), findsOneWidget);
        expect(find.text('Payment details'), findsOneWidget);
        expect(find.textContaining('Paid on'), findsOneWidget);

        await tester.tap(find.text('Hide details'));
        await tester.pumpAndSettle();

        expect(find.text('Show details'), findsNWidgets(2));
        expect(find.text('Hide details'), findsNothing);
        expect(find.text('Description'), findsNWidgets(2));
      },
    );

    testWidgets(
      'should display correct duration format and correct price formatting',
      (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());

        await tester.tap(find.text('Show details').first);
        await tester.pumpAndSettle();

        expect(find.text('12'), findsOneWidget);
        expect(find.text('months'), findsOneWidget);

        expect(find.text('€500.00'), findsOneWidget);

        await tester.tap(find.text('Hide details'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show details').last);
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('month'), findsOneWidget);

        expect(find.text('€50.00'), findsOneWidget);
      },
    );

    testWidgets('should show "No subscriptions found" when list is empty', (
      WidgetTester tester,
    ) async {
      final userWithoutSubscriptions = User(
        uid: 'test-uid',
        displayName: 'Test User',
        email: 'test@example.com',
        subscriptions: [],
        isAdmin: false,
        favouriteGyms: [],
      );

      reset(mockUserProvider);
      when(mockUserProvider.user).thenReturn(userWithoutSubscriptions);
      when(mockUserProvider.hasListeners).thenReturn(false);
      when(mockUserProvider.addListener(any)).thenAnswer((_) {});
      when(mockUserProvider.removeListener(any)).thenAnswer((_) {});
      when(mockUserProvider.fetchUser()).thenAnswer((_) async {});

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(home: Subscriptions()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No subscriptions found'), findsOneWidget);
      expect(find.text('PREMIUM PLAN'), findsNothing);
      expect(find.text('MONTHLY PLAN'), findsNothing);
      expect(find.text('Show details'), findsNothing);
    });

    testWidgets('should display animated arrow rotation when expanding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down).first);
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedRotation), findsWidgets);
    });
  });

  group('Subscriptions Refresh Tests', () {
    testWidgets(
      'should refresh subscriptions when pulled down and show success message after successful refresh',
      (WidgetTester tester) async {
        when(mockUserProvider.fetchUser()).thenAnswer((_) async {});
        await tester.pumpWidget(createTestWidget());

        await tester.fling(find.byType(RefreshIndicator), Offset(0, 300), 1000);
        await tester.pumpAndSettle();

        verify(mockUserProvider.fetchUser()).called(1);
        expect(find.text('Subscriptions updated successfully'), findsOneWidget);
      },
    );

    testWidgets('should show error message on refresh failure', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.fetchUser()).thenThrow(Exception('Network error'));
      await tester.pumpWidget(createTestWidget());

      await tester.fling(find.byType(RefreshIndicator), Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Error refreshing subscriptions'),
        findsOneWidget,
      );
    });
  });

  group('Subscriptions Date Formatting Tests', () {
    testWidgets('should format dates correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Show details').first);
      await tester.pumpAndSettle();

      final now = DateTime.now();
      final expectedDateString =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      expect(find.textContaining(expectedDateString), findsWidgets);
    });

    testWidgets('should handle null dates gracefully', (
      WidgetTester tester,
    ) async {
      final subscriptionWithNullDates = [
        Subscription(
          id: 'sub-null',
          title: 'Test Plan',
          description: 'Test description',
          startTime: null,
          paymentDate: null,
          expiryDate: DateTime.now().add(Duration(days: 30)),
          price: 100.0,
          duration: 1,
        ),
      ];

      final userWithNullDates = User(
        uid: 'test-uid',
        displayName: 'Test User',
        email: 'test@example.com',
        subscriptions: subscriptionWithNullDates,
        isAdmin: false,
        favouriteGyms: [],
      );

      reset(mockUserProvider);
      when(mockUserProvider.user).thenReturn(userWithNullDates);
      when(mockUserProvider.hasListeners).thenReturn(false);
      when(mockUserProvider.addListener(any)).thenAnswer((_) {});
      when(mockUserProvider.removeListener(any)).thenAnswer((_) {});
      when(mockUserProvider.fetchUser()).thenAnswer((_) async {});

      await tester.pumpWidget(
        ChangeNotifierProvider<UserProvider>.value(
          value: mockUserProvider,
          child: MaterialApp(home: Subscriptions()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show details'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('TEST PLAN'), findsOneWidget);
      expect(find.text('Test description'), findsOneWidget);
      expect(find.text('€100.00'), findsOneWidget);

      expect(find.text('Start date'), findsOneWidget);
      expect(find.text('Payment details'), findsOneWidget);
    });
  });

  group('Subscriptions UI Interaction Tests', () {
    testWidgets('should filter subscriptions correctly by date', (
      WidgetTester tester,
    ) async {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      await tester.pumpWidget(createTestWidget());

      final validSubscriptions =
          testSubscriptions
              .where(
                (s) =>
                    s.expiryDate != null && s.expiryDate!.isAfter(startOfDay),
              )
              .length;

      expect(find.text('PREMIUM PLAN'), findsOneWidget);
      expect(find.text('MONTHLY PLAN'), findsOneWidget);

      await tester.tap(find.text('Expired'));
      await tester.pumpAndSettle();

      expect(find.text('BASIC PLAN'), findsOneWidget);
    });
  });
}
