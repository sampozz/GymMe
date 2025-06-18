import 'package:gymme/content/profile/subscription/fetch_subscription.dart';
import 'package:gymme/content/profile/subscription/new_subscription.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../provider_test.mocks.dart';

void main() {
  late MockUserProvider mockUserProvider;
  late MockScreenProvider mockScreenProvider;
  late List<User> testUsers;

  setUp(() {
    mockUserProvider = MockUserProvider();
    mockScreenProvider = MockScreenProvider();

    testUsers = [
      User(
        uid: 'user1',
        displayName: 'John Doe',
        email: 'john@example.com',
        photoURL: '',
        isAdmin: false,
        favouriteGyms: [],
        subscriptions: [],
      ),
      User(
        uid: 'user2',
        displayName: 'Jane Smith',
        email: 'jane@example.com',
        photoURL: '',
        isAdmin: false,
        favouriteGyms: [],
        subscriptions: [],
      ),
      User(
        uid: 'user3',
        displayName: 'Bob Wilson',
        email: 'bob@example.com',
        photoURL: '',
        isAdmin: false,
        favouriteGyms: [],
        subscriptions: [],
      ),
    ];

    when(mockScreenProvider.useMobileLayout).thenReturn(false);
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(value: mockUserProvider),
        ChangeNotifierProvider<ScreenProvider>.value(value: mockScreenProvider),
      ],
      child: MaterialApp(home: FetchSubscription()),
    );
  }

  group('FetchSubscription Widget Tests', () {
    testWidgets('should show loading indicator and then display user list', (
      WidgetTester tester,
    ) async {
      final completer = Completer<List<User>>();
      when(mockUserProvider.getUserList()).thenAnswer((_) => completer.future);

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('John Doe'), findsNothing);

      completer.complete(testUsers);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('jane@example.com'), findsOneWidget);
      expect(find.text('Bob Wilson'), findsOneWidget);
      expect(find.text('bob@example.com'), findsOneWidget);

      expect(find.byType(CircleAvatar), findsNWidgets(testUsers.length));
      expect(
        find.byIcon(Icons.arrow_forward_ios),
        findsNWidgets(testUsers.length),
      );
    });

    testWidgets('should show "No users found" when list is empty', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.getUserList()).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No users found'), findsOneWidget);
    });

    testWidgets(
      'should display search bar with correct hint text and filter users by name (or by email) when searching',
      (WidgetTester tester) async {
        when(mockUserProvider.getUserList()).thenAnswer((_) async => testUsers);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SearchBar), findsOneWidget);
        expect(
          find.text('Search for a user by name or email...'),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.search), findsOneWidget);

        await tester.enterText(find.byType(SearchBar), 'John');
        await tester.pump();

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsNothing);
        expect(find.text('Bob Wilson'), findsNothing);

        await tester.enterText(find.byType(SearchBar), 'jane@');
        await tester.pump();

        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('John Doe'), findsNothing);
        expect(find.text('Bob Wilson'), findsNothing);
      },
    );

    testWidgets(
      'should show clear button when search text is entered and clear search when tapped',
      (WidgetTester tester) async {
        when(mockUserProvider.getUserList()).thenAnswer((_) async => testUsers);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(SearchBar), 'John');
        await tester.pump();

        expect(find.byIcon(Icons.clear), findsOneWidget);

        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('Bob Wilson'), findsOneWidget);
      },
    );

    testWidgets('should navigate to NewSubscription when user is tapped', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.getUserList()).thenAnswer((_) async => testUsers);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(NewSubscription), findsOneWidget);
    });

    testWidgets('should handle users with empty display names', (
      WidgetTester tester,
    ) async {
      final usersWithEmptyNames = [
        User(
          uid: 'user1',
          displayName: '',
          email: 'noname@example.com',
          photoURL: '',
          isAdmin: false,
          favouriteGyms: [],
          subscriptions: [],
        ),
      ];
      when(
        mockUserProvider.getUserList(),
      ).thenAnswer((_) async => usersWithEmptyNames);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('No Name'), findsOneWidget);
      expect(find.text('noname@example.com'), findsOneWidget);
    });

    testWidgets('should show correct app bar title', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.getUserList()).thenAnswer((_) async => testUsers);

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Members'), findsOneWidget);
    });

    testWidgets('should add bottom padding when using mobile layout', (
      WidgetTester tester,
    ) async {
      when(mockUserProvider.getUserList()).thenAnswer((_) async => testUsers);
      when(mockScreenProvider.useMobileLayout).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}
