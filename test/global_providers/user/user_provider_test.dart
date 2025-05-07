import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import '../../firestore_test.mocks.dart';
import '../../service_test.mocks.dart';

void main() {
  late MockUserService mockUserService;
  late MockFirebaseAuth mockFirebaseAuth;
  late UserProvider userProvider;
  late MockUser mockFirebaseUser;
  late MockUserCredential mockUserCredential;

  setUp(() {
    mockUserService = MockUserService();
    mockFirebaseAuth = MockFirebaseAuth();
    userProvider = UserProvider(
      userService: mockUserService,
      authInstance: mockFirebaseAuth,
    );
    mockFirebaseUser = MockUser();
    mockUserCredential = MockUserCredential();
  });

  group('UserProvider', () {
    test('signIn should return null if authentication fails', () async {
      when(
        mockUserService.signInWithEmailAndPassword('test', 'test'),
      ).thenAnswer((_) async => null);
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      var res = await userProvider.signIn('test', 'test');
      expect(res, null);
    });

    test(
      'signIn should return null if user is not found in Firestore',
      () async {
        when(
          mockUserService.signInWithEmailAndPassword('test', 'test'),
        ).thenAnswer((_) async => mockUserCredential);
        when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
        when(
          mockUserService.fetchUser(mockFirebaseUser),
        ).thenAnswer((_) async => null);
        var res = await userProvider.signIn('test', 'test');
        expect(res, null);
      },
    );

    test(
      'signIn should return user if auth and Firestore fetch succeed',
      () async {
        when(
          mockUserService.signInWithEmailAndPassword('test', 'test'),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

        User testUser = User(email: 'test');

        when(
          mockUserService.fetchUser(mockFirebaseUser),
        ).thenAnswer((_) async => testUser);

        var res = await userProvider.signIn('test', 'test');

        expect(res, testUser);
      },
    );

    test('signOut should make the user null', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      await userProvider.signOut();
      expect(userProvider.user, null);
    });

    test('getter on user should fetch the user if not set', () async {
      when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
      User testUser = User(email: 'test');

      when(
        mockUserService.fetchUser(mockFirebaseUser),
      ).thenAnswer((_) async => testUser);
      userProvider.user;

      verify(mockUserService.fetchUser(mockFirebaseUser)).called(1);
    });

    test('getter on isAdmin should return false if user is null', () {
      expect(userProvider.isAdmin, false);
    });

    test('getUsersByIds should return a list of users', () async {
      List<String> ids = ['1', '2'];
      List<User> users = [User(uid: '1'), User(uid: '2')];
      when(mockUserService.fetchUsers()).thenAnswer((_) async => users);
      var res = await userProvider.getUsersByIds(ids);
      expect(res, users);
    });

    test('addFavouriteGym should call the service method', () async {
      when(
        mockUserService.signInWithEmailAndPassword('test', 'test'),
      ).thenAnswer((_) async => mockUserCredential);

      when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

      User testUser = User(email: 'test', favouriteGyms: []);

      when(
        mockUserService.fetchUser(mockFirebaseUser),
      ).thenAnswer((_) async => testUser);

      await userProvider.signIn('test', 'test');

      when(
        mockUserService.updateUserFavourites(testUser),
      ).thenAnswer((_) async {});
      await userProvider.addFavouriteGym('gymId');
      expect(userProvider.user!.favouriteGyms, ['gymId']);
    });

    test('removeFavouriteGym should call the service method', () async {
      when(
        mockUserService.signInWithEmailAndPassword('test', 'test'),
      ).thenAnswer((_) async => mockUserCredential);

      when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);

      User testUser = User(email: 'test', favouriteGyms: ['gymId']);

      when(
        mockUserService.fetchUser(mockFirebaseUser),
      ).thenAnswer((_) async => testUser);

      await userProvider.signIn('test', 'test');

      when(
        mockUserService.updateUserFavourites(testUser),
      ).thenAnswer((_) async {});
      await userProvider.removeFavouriteGym('gymId');
      expect(userProvider.user!.favouriteGyms, []);
    });
  });
}
