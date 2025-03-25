import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/global_providers/user/user_model.dart';

class UserService {
  /// This method will sign in the user with the provided email and password
  Future<auth.UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    auth.UserCredential? userCredential;
    // Sign in with email and password
    try {
      userCredential = await auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      // TODO: Handle authentication error
    }
    return userCredential;
  }

  /// This method will sign out the user
  Future<void> signOut() async {
    await auth.FirebaseAuth.instance.signOut();
  }

  /// This method will fetch the user data from Firestore
  /// If the user is not found in Firestore, the method will return null
  /// If the user is found in Firestore, the method will return a User model object
  Future<User?> fetchUser(auth.User firebaseUser) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

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
}
