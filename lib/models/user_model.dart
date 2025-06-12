import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/subscription_model.dart';

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
  DateTime? certificateExpDate;
  List<Subscription> subscriptions;

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
    this.certificateExpDate,
    this.subscriptions = const [],
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
      certificateExpDate:
          data['certificateExpDate']?.toDate() ?? User().certificateExpDate,
      subscriptions:
          data['subscriptions'] == null
              ? []
              : data['subscriptions']
                  .map<Subscription>(
                    (subscription) => Subscription.fromFirestore(subscription),
                  )
                  .toList(),
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
      'certificateExpDate': certificateExpDate,
      'subscriptions':
          subscriptions
              .map((subscription) => subscription.toFirestore())
              .toList(),
    };
  }
}
