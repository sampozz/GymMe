import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';

class Gym {
  String? id;
  String name;
  String description;
  String address;
  String phone;
  List<Activity> activities;
  String imageUrl;
  DateTime? openTime;
  DateTime? closeTime;

  Gym({
    this.id,
    this.name = '',
    this.description = '',
    this.address = '',
    this.phone = '',
    this.activities = const [],
    this.imageUrl = '',
    this.openTime,
    this.closeTime,
  });

  factory Gym.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Gym(
      id: snapshot.id,
      name: data['name'] ?? Gym().name,
      description: data['description'] ?? Gym().description,
      address: data['address'] ?? Gym().address,
      phone: data['phone'] ?? Gym().phone,
      activities:
          data['activities'] == null
              ? []
              : data['activities']
                  .map<Activity>((activity) => Activity.fromFirestore(activity))
                  .toList(),
      imageUrl: data['imageUrl'] ?? Gym().imageUrl,
      openTime: data['openTime']?.toDate() ?? DateTime(0),
      closeTime: data['closeTime']?.toDate() ?? DateTime(0),
    );
  }

  Gym copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    List<Activity>? activities,
    String? imageUrl,
    DateTime? openTime,
    DateTime? closeTime,
  }) {
    return Gym(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      activities: activities ?? this.activities,
      imageUrl: imageUrl ?? this.imageUrl,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'activities':
          activities.map((activity) => activity.toFirestore()).toList(),
      'imageUrl': imageUrl,
      'openTime': openTime,
      'closeTime': closeTime,
    };
  }
}
