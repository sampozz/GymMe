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

  factory Slot.fromJson(String id, Map<String, dynamic> json) {
    return Slot(
      id: id,
      gym: null,
      activity: null,
      start: DateTime(0, 0),
      duration: json['duration'],
      maxUsers: json['maxUsers'],
      bookedUsers: List<String>.from(json['bookedUsers']),
    );
  }
}
