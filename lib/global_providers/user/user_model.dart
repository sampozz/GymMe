class User {
  String userName;
  bool isGuest;
  String level;

  User({
    this.userName = 'Preben',
    this.isGuest = false,
    this.level = 'beginner',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['userName'] ?? User().userName,
      isGuest: json['isGuest'] ?? User().isGuest,
      level: json['level'] ?? User().level,
    );
  }
}
