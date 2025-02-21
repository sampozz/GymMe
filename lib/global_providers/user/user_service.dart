import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/global_providers/user/user_model.dart';

class UserService {
  Future<User?> getUser() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String? userId = auth.FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return null;
    }

    DocumentSnapshot userDoc =
        await firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      return null;
    }

    var data = userDoc.data() as Map<String, dynamic>;
    return User.fromJson(data);
  }
}
