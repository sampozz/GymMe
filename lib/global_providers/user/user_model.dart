class User {
  String displayName;
  String email;
  String photoURL;
  String phoneNumber;
  bool isAdmin;

  User({
    this.displayName = '',
    this.email = '',
    this.photoURL = '',
    this.phoneNumber = '',
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      displayName: json['displayName'] ?? User().displayName,
      email: json['email'] ?? User().email,
      photoURL: json['photoURL'] ?? User().photoURL,
      phoneNumber: json['phoneNumber'] ?? User().phoneNumber,
      isAdmin: json['isAdmin'] ?? User().isAdmin,
    );
  }
}
