import 'package:dima_project/content/home/gym/activity/activity_model.dart';

class Gym {
  String id;
  String name;
  String address;
  String phone;
  List<Activity> activities;

  Gym({
    this.id = '',
    this.name = '',
    this.address = '',
    this.phone = '',
    this.activities = const [],
  });

  factory Gym.fromJson(String? id, Map<String, dynamic> json) {
    return Gym(
      id: id ?? Gym().id,
      name: json['name'] ?? Gym().name,
      address: json['address'] ?? Gym().address,
      phone: json['phone'] ?? Gym().phone,
      activities:
          json['activities'] != null
              ? (json['activities'] as List)
                  .map((activity) => Activity.fromJson(activity))
                  .toList()
              : [],
    );
  }
}
