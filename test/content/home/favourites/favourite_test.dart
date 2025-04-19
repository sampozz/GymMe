import 'package:dima_project/content/home/gym/gym_card.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../../global_providers/user/user_provider_test.mocks.dart';

// Create a mock of UserProvider
class MockUserProvider extends Mock implements UserProvider {}

void main() {
  // late User testUser;
  // late MockUserService mockUserService;
  // late UserProvider userProvider;
  // late MockFirebaseAuth mockFirebaseAuth;
  // late MockUser mockFirebaseUser;
  // late MockUserCredential mockUserCredential;

  // // Initializes mockUserProvider and testUser before each test is run
  // setUp(() {
  //   testUser = User(uid: 'testUid', favouriteGyms: []);
  //   mockUserService = MockUserService();
  //   mockFirebaseUser = MockUser();
  //   mockUserCredential = MockUserCredential();
  //   when(
  //     mockUserService.updateUserFavourites(any),
  //   ).thenAnswer((_) async => null);
  //   when(
  //     mockUserService.fetchUser(mockFirebaseUser),
  //   ).thenAnswer((_) async => testUser);
  //   when(
  //     mockUserService.signInWithEmailAndPassword('', ''),
  //   ).thenAnswer((_) async => mockUserCredential);
  //   mockFirebaseAuth = MockFirebaseAuth();
  //   when(mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
  //   userProvider = UserProvider(
  //     userService: mockUserService,
  //     authInstance: mockFirebaseAuth,
  //   );
  // });
  /*
  group('Favourite tests', () {
    test('should add gym to favourites', () {
      final gymId = 'gym1';

      userProvider.signIn("", "");

      // Simulate adding a gym to favourites
      userProvider.addFavouriteGym(gymId);
      expect(testUser.favouriteGyms.contains(gymId), true);
    });

    test('Should remove gym from favourites', () {
      final gymId = 'gym1';
      testUser.favouriteGyms.add(gymId);

      // Simulate removing a gym from favourites
      userProvider.removeFavouriteGym(gymId);

      // Verify that the gym was removed from the favourite list
      verify(userProvider.removeFavouriteGym(gymId)).called(1);
      expect(testUser.favouriteGyms.contains(gymId), false);
    });

    testWidgets(
      'Icon should turn red when clicked and gray when clicked again',
      (WidgetTester tester) async {
        // Stub the gym list to return a gym
        final gym = Gym(
          id: 'gym1',
          name: 'Gym 1',
          address: 'Address 1',
          phone: '1234567890',
        );

        // Build the GymCard widget
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<UserProvider>.value(value: userProvider),
            ],
            child: MaterialApp(home: GymCard(gymIndex: 0)),
          ),
        );

        // Verify the initial state of the icon (should be gray)
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);

        // Simulate tapping the favorite icon
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Verify the icon turns red (favorite)
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        expect(find.byIcon(Icons.favorite_border), findsNothing);

        // Simulate tapping the favorite icon again
        await tester.tap(find.byIcon(Icons.favorite));
        await tester.pumpAndSettle();

        // Verify the icon turns gray (not favorite)
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsNothing);
      },
    );
  });
  */
}
