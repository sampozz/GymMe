import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  final auth.FirebaseAuth _auth;
  User? _user;

  // Constructor with dependency injection
  UserProvider({UserService? userService, auth.FirebaseAuth? authInstance})
    : _userService = userService ?? UserService(),
      _auth = authInstance ?? auth.FirebaseAuth.instance;

  // Get user model stored in the provider
  User? get user {
    if (_user == null && isLoggedIn) {
      // If the user is not set, but it is logged in, fetch the user data from Firestore
      _userService.fetchUser(_auth.currentUser!).then((value) {
        _user = value;
        notifyListeners();
      });
    }
    return _user;
  }

  // Getter to check if the user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Getter to check if the user is an admin
  bool get isAdmin => _user?.isAdmin ?? false;

  /// This method will sign in the user with the provided email and password
  /// If the user is successfully signed in, the user data will be fetched from Firestore
  /// and stored in the _user property
  /// If the user is not found in Firestore, the _user property will be set to null
  Future<User?> signIn(String email, String password) async {
    // Sign in with email and password
    await _userService.signInWithEmailAndPassword(email, password);
    // Get the current firebase user, this user is needed to fetch the user data from Firestore
    return fetchUser();
  }

  Future<User?> signInWithGoogle() async {
    // Sign in with Google
    auth.UserCredential? userCredential = await _userService.signInWithGoogle();
    if (userCredential != null) {
      // Get the current firebase user, this user is needed to fetch the user data from Firestore
      User? user = await fetchUser();
      if (user == null) {
        // If the user is not found in Firestore, create a new user
        await createUser(userCredential.user!.displayName!);
        user = await fetchUser();
      }
      return user;
    }
    return null;
  }

  Future<String?> signUp(String email, String password, String fullName) async {
    // Sign up with email and password
    try {
      await _userService.signUpWithEmailAndPassword(email, password);
      createUser(fullName);
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    }
    return null;
  }

  Future<User?> createUser(String fullName) async {
    // Get the current firebase user, this user is needed to fetch the user data from Firestore
    auth.User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      // TODO: Handle authentication error
      return null;
    }
    _user = User(
      uid: firebaseUser.uid,
      displayName: fullName,
      email: firebaseUser.email!,
      favouriteGyms: [],
    );
    try {
      await _userService.createUser(_user!);
    } catch (e) {
      return null;
    }
    notifyListeners();
    return _user;
  }

  /// This method will sign out the user and set the _user property to null
  Future<void> signOut() async {
    await _userService.signOut();
    _user = null;
    notifyListeners();
  }

  /// This method will fetch the user data from Firestore
  /// If the user is not found in Firestore, the method will return null
  Future<User?> fetchUser() async {
    auth.User? firebaseUser = _auth.currentUser;

    if (firebaseUser == null) {
      // TODO: Handle authentication error
      return null;
    }

    // Fetch the user data from Firestore
    _user = await _userService.fetchUser(firebaseUser);

    if (_user == null) {
      // TODO: Handle user not found in Firestore
      return null;
    }

    notifyListeners();
    return _user;
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _userService.resetPassword(email);
    } on auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is badly formatted.';
      }
    }
    return null;
  }

  Future<List<User>> getUsersByIds(List<String> ids) async {
    // Fetch the user data from Firestore
    List<User> users = await _userService.fetchUsers();
    users = users.where((user) => ids.contains(user.uid)).toList();
    return users;
  }

  /// This method will add a gym to the favourite gyms list of the user
  Future<void> addFavouriteGym(String gymId) async {
    if (_user != null) {
      _user!.favouriteGyms.add(gymId);
      notifyListeners();
      await _userService.updateUserFavourites(_user!);
    }
  }

  /// This method will remove a gym from the favourite gyms list of the user
  Future<void> removeFavouriteGym(String gymId) async {
    if (_user != null) {
      _user!.favouriteGyms.remove(gymId);
      notifyListeners();
      await _userService.updateUserFavourites(_user!);
    }
  }

  bool isGymInFavourites(String gymId) {
    if (_user == null) {
      return false;
    }
    return _user!.favouriteGyms.contains(gymId);
  }
}
