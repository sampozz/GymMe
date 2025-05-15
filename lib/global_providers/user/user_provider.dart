import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/profile/subscription/subscription_model.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService;
  final auth.FirebaseAuth _auth;
  User? _user;
  List<User>? _userList;

  /// Getter for the user list. If the list is null, fetch it from the service.
  List<User>? get userList {
    if (_userList == null) {
      getUserList();
    }
    return _userList;
  }

  /// Returns a list of User objects.
  Future<List<User>> getUserList() async {
    var data = await _userService.fetchUserList();
    _userList = data;
    notifyListeners();
    return data;
  }

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
      // Authentication error
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
      // Authentication error
      return null;
    }

    // Fetch the user data from Firestore
    _user = await _userService.fetchUser(firebaseUser);

    if (_user == null) {
      // User not found in Firestore
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

  /// Adds a new subscription to the user list.
  Future<void> addSubscription(User user, Subscription subscription) async {
    var index = _userList!.indexWhere((element) => element.uid == user.uid);
    _userList![index].subscriptions.add(subscription);
    await _userService.setSubscription(user);
    notifyListeners();
  }

  /// Removes the account of the user.
  Future<void> deleteAccount(String uid) async {
    auth.User? firebaseUser = _auth.currentUser;
    await firebaseUser?.delete();
    await _userService.removeAccount(uid);
  }

  /// Updates the medical certificate of the user.
  Future<void> updateMedicalCertificate(
    String uid,
    DateTime certificateExpDate,
  ) async {
    await _userService.updateMedicalCertificate(uid, certificateExpDate);
    notifyListeners();
  }

  /// Uploads an image to the gym service and returns the URL.
  Future<String> uploadImage(String base64Image) async {
    String imageUrl = await _userService.uploadImage(base64Image);
    return imageUrl;
  }
}
