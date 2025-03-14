import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';

class Slot {
  final String id;
  Gym? gym;
  Activity? activity;
  final DateTime? start;
  final int duration;
  final int maxUsers;
  final List<String> bookedUsers;

  Slot({
    this.id = '',
    this.gym,
    this.activity,
    this.start,
    this.duration = 0,
    this.maxUsers = 0,
    this.bookedUsers = const [],
  });

  factory Slot.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Slot(
      id: snapshot.id,
      gym: null,
      activity: null,
      start: data['start']?.toDate() ?? DateTime(0),
      duration: data['duration'] ?? Slot().duration,
      maxUsers: data['maxUsers'] ?? Slot().maxUsers,
      bookedUsers: List<String>.from(data['bookedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'start': start,
      if (gym != null) 'gymId': gym!.id,
      if (activity != null) 'activityId': activity!.id,
      'duration': duration,
      'maxUsers': maxUsers,
      'bookedUsers': bookedUsers,
    };
  }
}
