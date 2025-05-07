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

  /// This method will update the user profile with the provided data
  Future<void> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? address,
    String? taxCode,
    String? birthPlace,
    DateTime? birthDate,
  }) async {
    if (_user != null) {
      _user!.displayName = displayName ?? _user!.displayName;
      _user!.phoneNumber = phoneNumber ?? _user!.phoneNumber;
      _user!.address = address ?? _user!.address;
      _user!.taxCode = taxCode ?? _user!.taxCode;
      _user!.birthPlace = birthPlace ?? _user!.birthPlace;
      _user!.birthDate = birthDate ?? _user!.birthDate;
      notifyListeners();
      await _userService.updateUserProfile(_user!);
    }
  }
}
