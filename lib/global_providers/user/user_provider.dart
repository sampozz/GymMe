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
      _userService.getUser(_auth.currentUser!).then((value) {
        _user = value;
        notifyListeners();
      });
    }
    return _user;
  }

  // Getter to check if the user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  /// This method will sign in the user with the provided email and password
  /// If the user is successfully signed in, the user data will be fetched from Firestore
  /// and stored in the _user property
  /// If the user is not found in Firestore, the _user property will be set to null
  Future<User?> signIn(String email, String password) async {
    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Get the current firebase user, this user is needed to fetch the user data from Firestore
      auth.User? firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        throw Exception("Auth error");
      }

      // Fetch the user data from Firestore
      _user = await _userService.getUser(firebaseUser);

      if (_user == null) {
        throw Exception("Firestore error");
      }

      notifyListeners();
    } catch (e) {
      // TODO: Handle authentication error
    }

    return _user;
  }

  /// This method will sign out the user and set the _user property to null
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }
}
