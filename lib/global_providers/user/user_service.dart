import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PlatformService {
  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb;
}

class UserService {
  final PlatformService _platformService;
  auth.FirebaseAuth firebaseAuth;
  FirebaseFirestore firestore;

  UserService({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firebaseFirestore,
    PlatformService? platformService,
  }) : firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
       firestore = firebaseFirestore ?? FirebaseFirestore.instance,
       _platformService = platformService ?? PlatformService();

  /// This method will sign in the user with the provided email and password
  Future<auth.UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    // Sign in with email and password
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<auth.UserCredential?> signInWithGoogle() async {
    if (_platformService.isWeb) {
      // Web sign-in
      final auth.GoogleAuthProvider googleProvider = auth.GoogleAuthProvider();
      googleProvider.addScope('email');
      return await firebaseAuth.signInWithPopup(googleProvider);
    } else {
      // Mobile sign-in
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('User cancelled the sign-in');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await firebaseAuth.signInWithCredential(credential);
    }
  }

  Future<auth.UserCredential?> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    auth.UserCredential? userCredential;
    userCredential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  /// This method will sign out the user
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  /// This method will fetch all the user from Firestore
  Future<List<User>> fetchUserList() async {
    List<User> userList = [];
    var usersRef =
        await firestore
            .collection('users')
            .withConverter(
              fromFirestore: User.fromFirestore,
              toFirestore: (User user, options) => user.toFirestore(),
            )
            .get();
    for (var doc in usersRef.docs) {
      userList.add(doc.data());
    }
    return userList;
  }

  /// This method will fetch the user data from Firestore
  /// If the user is not found in Firestore, the method will return null
  /// If the user is found in Firestore, the method will return a User model object
  Future<User?> fetchUser(auth.User firebaseUser) async {
    // Get user document from Firestore
    var userDoc =
        await firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .withConverter(
              fromFirestore: User.fromFirestore,
              toFirestore: (user, options) => user.toFirestore(),
            )
            .get();

    if (!userDoc.exists) {
      // User not found in Firestore
      return null;
    }

    // Create and return User object
    return userDoc.data();
  }

  Future<void> createUser(User user) async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .withConverter(
          fromFirestore: User.fromFirestore,
          toFirestore: (user, options) => user.toFirestore(),
        )
        .set(user);
  }

  /// This method will reset the password for the user with the provided email
  Future<void> resetPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// This method will update the user favourite gyms in Firestore
  Future<void> updateUserFavourites(User user) async {
    await firestore.collection('users').doc(user.uid).update({
      'favouriteGyms': user.favouriteGyms,
    });
  }

  Future<List<User>> fetchUsers() async {
    List<User> users = [];
    var usersRef =
        await firestore
            .collection('users')
            .withConverter(
              fromFirestore: User.fromFirestore,
              toFirestore: (user, options) => user.toFirestore(),
            )
            .get();
    users = usersRef.docs.map((doc) => doc.data()).toList();
    return users;
  }

  /// This method will update the user profile in Firestore
  Future<void> updateUserProfile(User user) async {
    await firestore.collection('users').doc(user.uid).update({
      'displayName': user.displayName,
      'phoneNumber': user.phoneNumber,
      'address': user.address,
      'taxCode': user.taxCode,
      'birthPlace': user.birthPlace,
      'birthDate': user.birthDate,
    });
  }

  /// Updates the user document in the Firestore 'user' collection with the new subscription.
  /// Throws a FirebaseException if there is an error during the set operation.
  /// Returns the id of the set subscription.
  Future<void> setSubscription(User user) async {
    await firestore.collection('users').doc(user.uid).update({
      'subscriptions':
          user.subscriptions
              .map((subscription) => subscription.toFirestore())
              .toList(),
    });
  }

  Future<void> updateMedicalCertificate(
    String uid,
    DateTime certificateExpDate,
  ) async {
    firestore.collection('users').doc(uid).update({
      'certificateExpDate': certificateExpDate,
    });
  }

  Future<void> removeAccount(String uid) async {
    await firestore.collection('users').doc(uid).delete();
  }
}
