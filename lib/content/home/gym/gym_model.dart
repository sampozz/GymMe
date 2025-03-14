import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';

class Gym {
  String? id;
  String name;
  String address;
  String phone;
  List<Activity> activities;

  Gym({
    this.id,
    this.name = '',
    this.address = '',
    this.phone = '',
    this.activities = const [],
  });

  factory Gym.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Gym(
      id: snapshot.id,
      name: data['name'] ?? Gym().name,
      address: data['address'] ?? Gym().address,
      phone: data['phone'] ?? Gym().phone,
      activities:
          data['activities'] == null
              ? []
              : data['activities']
                  .map<Activity>((activity) => Activity.fromFirestore(activity))
                  .toList(),
    );
  }

  Gym copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    List<Activity>? activities,
  }) {
    return Gym(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      activities: activities ?? this.activities,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'activities':
          activities.map((activity) => activity.toFirestore()).toList(),
    };
  }
}
