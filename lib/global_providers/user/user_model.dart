import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String displayName;
  String email;
  String photoURL;
  String phoneNumber;
  bool isAdmin;

  User({
    this.uid = '',
    this.displayName = '',
    this.email = '',
    this.photoURL = '',
    this.phoneNumber = '',
    this.isAdmin = false,
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return User(
      uid: data['uid'] ?? User().uid,
      displayName: data['displayName'] ?? User().displayName,
      email: data['email'] ?? User().email,
      photoURL: data['photoURL'] ?? User().photoURL,
      phoneNumber: data['phoneNumber'] ?? User().phoneNumber,
      isAdmin: data['isAdmin'] ?? User().isAdmin,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'isAdmin': isAdmin,
    };
  }
}
