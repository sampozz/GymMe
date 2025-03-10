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

  factory User.fromJson(String? uid, Map<String, dynamic> json) {
    return User(
      uid: uid ?? User().uid,
      displayName: json['displayName'] ?? User().displayName,
      email: json['email'] ?? User().email,
      photoURL: json['photoURL'] ?? User().photoURL,
      phoneNumber: json['phoneNumber'] ?? User().phoneNumber,
      isAdmin: json['isAdmin'] ?? User().isAdmin,
    );
  }
}
