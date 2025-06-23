import 'package:gymme/models/subscription_model.dart';
import 'package:gymme/models/user_model.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../firestore_test.mocks.dart';
import '../service_test.mocks.dart';

void main() {
  late UserProvider userProvider;
  late MockUserService mockUserService;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockFirebaseUser;

  // Sample user data for testing
  final testUser = User(
    uid: 'test-uid',
    displayName: 'Test User',
    email: 'test@example.com',
    favouriteGyms: ['gym1', 'gym2'],
    phoneNumber: '1234567890',
    address: '123 Test St',
    taxCode: 'TEST123',
    birthPlace: 'Test City',
    birthDate: DateTime(1990, 1, 1),
    isAdmin: false,
    subscriptions: [],
  );

  setUp(() {
    mockUserService = MockUserService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseUser = MockUser();

    // Set up common mock behaviors
    when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
    when(mockFirebaseUser.uid).thenReturn('test-uid');
    when(mockFirebaseUser.email).thenReturn('test@example.com');
    when(mockFirebaseUser.displayName).thenReturn('Test User');

    userProvider = UserProvider(
      userService: mockUserService,
      authInstance: mockFirebaseAuth,
    );
  });

  group('UserModel', () {
    test('should create a UserModel instance with correct properties', () {
      final user = User(uid: 'test-uid', displayName: 'Test User');

      expect(user.uid, 'test-uid');
      expect(user.displayName, 'Test User');
    });

    test(
      'user fromFirestore should create a UserModel from Firestore data',
      () {
        final snapshot = MockDocumentSnapshot<Map<String, dynamic>>();
        final data = {'displayName': 'Test User', 'email': 'email'};

        when(snapshot.id).thenReturn('test-uid');
        when(snapshot.data()).thenReturn(data);

        final user = User.fromFirestore(snapshot, null);
        expect(user.uid, 'test-uid');
      },
    );

    test('user toFirestore should convert UserModel to Firestore data', () {
      final user = User(
        uid: 'test-uid',
        displayName: 'Test User',
        email: 'email',
      );

      final data = user.toFirestore();
      expect(data['uid'], 'test-uid');
      expect(data['displayName'], 'Test User');
    });
  });

  group('UserProvider initialization and getters', () {
    test('should initialize with null user', () {
      expect(userProvider.user, null);
    });

    test('isLoggedIn should return true when current user is not null', () {
      expect(userProvider.isLoggedIn, true);
    });

    test('isLoggedIn should return false when current user is null', () {
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      expect(userProvider.isLoggedIn, false);
    });

    test('isAdmin should return false initially when user is null', () {
      userProvider = UserProvider(
        userService: mockUserService,
        authInstance: mockFirebaseAuth,
      );
      expect(userProvider.isAdmin, false);
    });

    test('isAdmin should return correct value from user', () async {
      // Arrange
      final adminUser = User(
        uid: 'admin-uid',
        displayName: 'Admin User',
        email: 'admin@example.com',
        favouriteGyms: [],
        isAdmin: true,
      );

      when(mockUserService.fetchUser(any)).thenAnswer((_) async => adminUser);

      // Act - trigger user fetch via getter
      await userProvider.fetchUser();

      // Assert
      expect(userProvider.isAdmin, true);
    });
  });

  group('User authentication', () {
    test('signIn should fetch user when successful', () async {
      // Arrange
      when(
        mockUserService.signInWithEmailAndPassword(
          'test@example.com',
          'password',
        ),
      ).thenAnswer((_) async => null);
      when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);

      // Act
      final result = await userProvider.signIn('test@example.com', 'password');

      // Assert
      expect(result, testUser);
      verify(
        mockUserService.signInWithEmailAndPassword(
          'test@example.com',
          'password',
        ),
      ).called(1);
      expect(userProvider.user, testUser);
    });

    test('signIn should return null when authentication fails', () async {
      // Arrange
      when(
        mockUserService.signInWithEmailAndPassword(
          'test@example.com',
          'wrong-password',
        ),
      ).thenThrow(auth.FirebaseAuthException(code: 'wrong-password'));

      // Act
      final result = await userProvider.signIn(
        'test@example.com',
        'wrong-password',
      );

      // Assert
      expect(result, null);
      verify(
        mockUserService.signInWithEmailAndPassword(
          'test@example.com',
          'wrong-password',
        ),
      ).called(1);
    });

    test('signInWithGoogle should fetch user when successful', () async {
      // Arrange
      final mockCredential = MockUserCredential();
      when(
        mockUserService.signInWithGoogle(),
      ).thenAnswer((_) async => mockCredential);
      when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);
      when(mockCredential.user).thenReturn(mockFirebaseUser);

      // Act
      final result = await userProvider.signInWithGoogle();

      // Assert
      expect(result, testUser);
      verify(mockUserService.signInWithGoogle()).called(1);
    });

    test(
      'signInWithGoogle should create new user when user not found in database',
      () async {
        // Arrange
        final mockCredential = MockUserCredential();
        when(
          mockUserService.signInWithGoogle(),
        ).thenAnswer((_) async => mockCredential);
        final responses = [null, testUser];
        when(
          mockUserService.fetchUser(any),
        ).thenAnswer((_) async => responses.removeAt(0));
        when(mockCredential.user).thenReturn(mockFirebaseUser);

        // Act
        final result = await userProvider.signInWithGoogle();

        // Assert
        expect(result, testUser);
        verify(mockUserService.createUser(any)).called(1);
      },
    );

    test(
      'signInWithGoogle should return null when authentication fails',
      () async {
        // Arrange
        when(mockUserService.signInWithGoogle()).thenAnswer((_) async => null);

        // Act
        final result = await userProvider.signInWithGoogle();

        // Assert
        expect(result, null);
      },
    );

    test('signUp should create user when successful', () async {
      // Arrange
      when(
        mockUserService.signUpWithEmailAndPassword(
          'test@example.com',
          'password',
        ),
      ).thenAnswer((_) async => null);
      when(mockUserService.createUser(any)).thenAnswer((_) async {});

      // Act
      final result = await userProvider.signUp(
        'test@example.com',
        'password',
        'Test User',
      );

      // Assert
      expect(result, null); // No error message means success
      verify(
        mockUserService.signUpWithEmailAndPassword(
          'test@example.com',
          'password',
        ),
      ).called(1);
      verify(mockUserService.createUser(any)).called(1);
    });

    test(
      'signUp should return error message when authentication fails',
      () async {
        // Arrange
        when(
          mockUserService.signUpWithEmailAndPassword(
            'test@example.com',
            'weak',
          ),
        ).thenThrow(auth.FirebaseAuthException(code: 'weak-password'));

        // Act
        final result = await userProvider.signUp(
          'test@example.com',
          'weak',
          'Test User',
        );

        // Assert
        expect(result, 'The password provided is too weak.');
      },
    );

    test('signOut should clear user data', () async {
      // Arrange
      when(mockUserService.signOut()).thenAnswer((_) async {});

      // Act
      await userProvider.signOut();

      // Assert
      expect(userProvider.user, null);
      verify(mockUserService.signOut()).called(1);
    });

    test(
      'resetPassword should call service and return null on success',
      () async {
        // Arrange
        when(
          mockUserService.resetPassword('test@example.com'),
        ).thenAnswer((_) async {});

        // Act
        final result = await userProvider.resetPassword('test@example.com');

        // Assert
        expect(result, null);
        verify(mockUserService.resetPassword('test@example.com')).called(1);
      },
    );

    test(
      'resetPassword should return error message when service throws',
      () async {
        // Arrange
        when(
          mockUserService.resetPassword('invalid'),
        ).thenThrow(auth.FirebaseAuthException(code: 'invalid-email'));

        // Act
        final result = await userProvider.resetPassword('invalid');

        // Assert
        expect(result, 'The email address is badly formatted.');
      },
    );
  });

  group('User data fetching', () {
    test('fetchUser should return user when found in database', () async {
      // Arrange
      when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);

      // Act
      final result = await userProvider.fetchUser();

      // Assert
      expect(result, testUser);
      expect(userProvider.user, testUser);
    });

    test(
      'fetchUser should return null when user not found in database',
      () async {
        // Arrange
        when(mockUserService.fetchUser(any)).thenAnswer((_) async => null);

        // Act
        final result = await userProvider.fetchUser();

        // Assert
        expect(result, null);
      },
    );

    test('fetchUser should return null when not authenticated', () async {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final result = await userProvider.fetchUser();

      // Assert
      expect(result, null);
    });

    test('getUserList should fetch and return user list', () async {
      // Arrange
      final userList = [testUser];
      when(mockUserService.fetchUsers()).thenAnswer((_) async => userList);

      // Act
      final result = await userProvider.getUserList();

      // Assert
      expect(result, userList);
      expect(userProvider.userList, userList);
    });

    test('userList getter should call getUserList when list is null', () async {
      // Arrange
      final userList = [testUser];
      when(mockUserService.fetchUsers()).thenAnswer((_) async => userList);

      // Act
      final result = userProvider.userList;

      // Assert
      expect(result, null); // Initially null before async operation completes
      await untilCalled(mockUserService.fetchUsers());
      verify(mockUserService.fetchUsers()).called(1);
    });

    test('getUsersByIds should return filtered users', () async {
      // Arrange
      final user1 = User(
        uid: 'uid1',
        displayName: 'User 1',
        email: 'user1@example.com',
        favouriteGyms: [],
      );
      final user2 = User(
        uid: 'uid2',
        displayName: 'User 2',
        email: 'user2@example.com',
        favouriteGyms: [],
      );
      final userList = [user1, user2];

      when(mockUserService.fetchUsers()).thenAnswer((_) async => userList);

      // Act
      final result = await userProvider.getUsersByIds(['uid1']);

      // Assert
      expect(result.length, 1);
      expect(result.first.uid, 'uid1');
    });
  });

  group('User profile management', () {
    setUp(() async {
      // Set up user for profile management tests
      when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);
      await userProvider.fetchUser();
    });

    test('updateUserProfile should update user properties', () async {
      // Arrange
      when(mockUserService.updateUserProfile(any)).thenAnswer((_) async {});

      // Act
      await userProvider.updateUserProfile(
        displayName: 'Updated Name',
        phoneNumber: '9876543210',
      );

      // Assert
      expect(userProvider.user?.displayName, 'Updated Name');
      expect(userProvider.user?.phoneNumber, '9876543210');
      // Other properties should remain unchanged
      expect(userProvider.user?.email, 'test@example.com');
      verify(mockUserService.updateUserProfile(any)).called(1);
    });

    test('updateMedicalCertificate should call service', () async {
      // Arrange
      final expiryDate = DateTime(2023, 12, 31);
      when(
        mockUserService.updateMedicalCertificate('test-uid', expiryDate),
      ).thenAnswer((_) async {});

      // Act
      await userProvider.updateMedicalCertificate('test-uid', expiryDate);

      // Assert
      verify(
        mockUserService.updateMedicalCertificate('test-uid', expiryDate),
      ).called(1);
    });
  });

  group('Favorite gyms management', () {
    setUp(() async {
      // Set up user for favorite gym tests
      when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);
      await userProvider.fetchUser();
    });

    test('addFavouriteGym should add gym to user favorites', () async {
      // Arrange
      when(mockUserService.updateUserFavourites(any)).thenAnswer((_) async {});

      // Act
      await userProvider.addFavouriteGym('gym3');

      // Assert
      expect(userProvider.user?.favouriteGyms, contains('gym3'));
      verify(mockUserService.updateUserFavourites(any)).called(1);
    });

    test('removeFavouriteGym should remove gym from user favorites', () async {
      // Arrange
      when(mockUserService.updateUserFavourites(any)).thenAnswer((_) async {});

      // Act
      await userProvider.removeFavouriteGym('gym1');

      // Assert
      expect(userProvider.user?.favouriteGyms, isNot(contains('gym1')));
      verify(mockUserService.updateUserFavourites(any)).called(1);
    });

    test(
      'isGymInFavourites should return true when gym is in favorites',
      () async {
        // Act & Assert
        final userProvider = UserProvider(
          authInstance: mockFirebaseAuth,
          userService: mockUserService,
        );
        User testUser = User(uid: 'test-uid', favouriteGyms: ['gym1', 'gym2']);
        when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);
        await userProvider.fetchUser();
        expect(userProvider.isGymInFavourites('gym1'), true);
      },
    );

    test(
      'isGymInFavourites should return false when gym is not in favorites',
      () async {
        // Act & Assert
        final userProvider = UserProvider(
          authInstance: mockFirebaseAuth,
          userService: mockUserService,
        );
        User testUser = User(uid: 'test-uid', favouriteGyms: ['gym1', 'gym2']);
        when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);
        await userProvider.fetchUser();
        expect(userProvider.isGymInFavourites('gym3'), false);
      },
    );

    test('isGymInFavourites should return false when user is null', () {
      // Arrange
      userProvider = UserProvider(
        userService: mockUserService,
        authInstance: mockFirebaseAuth,
      );

      // We need to ensure user is null for this test
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(userProvider.isGymInFavourites('gym1'), false);
    });
  });

  group('Subscription management', () {
    test('addSubscription should add subscription to user', () async {
      // Arrange
      final userList = [testUser];
      final subscription = Subscription(gymId: 'gym1', price: 100.0);

      when(mockUserService.fetchUsers()).thenAnswer((_) async => userList);
      when(mockUserService.setSubscription(any)).thenAnswer((_) async {});

      // First get the user list
      await userProvider.getUserList();

      // Act
      await userProvider.addSubscription(testUser, subscription);

      // Assert
      expect(userProvider.userList?[0].subscriptions, contains(subscription));
      verify(mockUserService.setSubscription(any)).called(1);
    });
  });

  group('Account management', () {
    test('deleteAccount should delete user account', () async {
      // Arrange
      when(mockFirebaseUser.delete()).thenAnswer((_) async {});
      when(mockUserService.removeAccount('test-uid')).thenAnswer((_) async {});

      // Act
      await userProvider.deleteAccount('test-uid');

      // Assert
      verify(mockFirebaseUser.delete()).called(1);
      verify(mockUserService.removeAccount('test-uid')).called(1);
    });
  });

  group('User getter behavior', () {
    test(
      'user getter should fetch user data when user is null but logged in',
      () async {
        // Arrange
        userProvider = UserProvider(
          userService: mockUserService,
          authInstance: mockFirebaseAuth,
        );
        when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);

        // Act
        final result = userProvider.user;

        // Assert
        expect(result, null); // Initially null before async fetch completes
        await untilCalled(mockUserService.fetchUser(any));
        verify(mockUserService.fetchUser(any)).called(1);
      },
    );

    test('user getter should not fetch when already loaded', () async {
      // Arrange
      when(mockUserService.fetchUser(any)).thenAnswer((_) async => testUser);
      await userProvider.fetchUser(); // Load user first
      clearInteractions(mockUserService);

      // Act
      final result = userProvider.user;

      // Assert
      expect(result, testUser); // Should return cached user
      verifyNever(mockUserService.fetchUser(any)); // Should not fetch again
    });
  });
}

// Mock class for UserCredential which is needed for Google sign in tests
class MockUserCredential extends Mock implements auth.UserCredential {}
