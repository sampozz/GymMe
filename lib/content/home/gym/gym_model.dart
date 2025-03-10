class Gym {
  String id;
  String name;
  String address;
  String phone;

  Gym({this.id = '', this.name = '', this.address = '', this.phone = ''});

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'] ?? Gym().id,
      name: json['name'] ?? Gym().name,
      address: json['address'] ?? Gym().address,
      phone: json['phone'] ?? Gym().phone,
    );
  }
}
