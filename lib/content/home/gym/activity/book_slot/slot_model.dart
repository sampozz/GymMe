import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  final String id;
  final String gymId;
  final String activityId;
  final DateTime? start;
  final int duration;
  final int maxUsers;
  final List<String> bookedUsers;

  Slot({
    this.id = '',
    this.gymId = '',
    this.activityId = '',
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
      gymId: data['gymId'] ?? Slot().gymId,
      activityId: data['activityId'] ?? Slot().activityId,
      start: data['start']?.toDate() ?? DateTime(0),
      duration: data['duration'] ?? Slot().duration,
      maxUsers: data['maxUsers'] ?? Slot().maxUsers,
      bookedUsers: List<String>.from(data['bookedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'start': start,
      'gymId': gymId,
      'activityId': activityId,
      'duration': duration,
      'maxUsers': maxUsers,
      'bookedUsers': bookedUsers,
    };
  }
}
