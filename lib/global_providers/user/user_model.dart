import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String uid;
  String displayName;
  String email;
  String photoURL;
  String phoneNumber;
  DateTime? birthDate;
  String birthPlace;
  String address;
  String taxCode;
  bool isAdmin;
  List<String> favouriteGyms;
  //List<String> subscriptions;

  User({
    this.uid = '',
    this.displayName = '',
    this.email = '',
    this.photoURL = 'assets/avatar.png',
    this.phoneNumber = '',
    this.birthDate,
    this.birthPlace = '',
    this.address = '',
    this.taxCode = '',
    this.isAdmin = false,
    this.favouriteGyms = const [],
    //this.subscriptions = const [],
  });

  factory User.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return User(
      uid: snapshot.id,
      displayName: data['displayName'] ?? User().displayName,
      email: data['email'] ?? User().email,
      photoURL: data['photoURL'] ?? User().photoURL,
      phoneNumber: data['phoneNumber'] ?? User().phoneNumber,
      birthDate: data['birthDate']?.toDate() ?? User().birthDate,
      birthPlace: data['birthPlace'] ?? User().birthPlace,
      address: data['address'] ?? User().address,
      taxCode: data['taxCode'] ?? User().taxCode,
      isAdmin: data['isAdmin'] ?? User().isAdmin,
      favouriteGyms: List<String>.from(data['favouriteGyms'] ?? []),
      //subscriptions: List<String>.from(data['subscriptions'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'birthPlace': birthPlace,
      'address': address,
      'taxCode': taxCode,
      'isAdmin': isAdmin,
      'favouriteGyms': favouriteGyms,
      //'subscriptions': subscriptions,
    };
  }
}
