import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  final String id;
  final String gymId;
  final String activityId;
  final DateTime startTime;
  final DateTime endTime;
  final int maxUsers;
  final String room;
  final List<String> bookedUsers;

  Slot({id, gymId, activityId, startTime, endTime, maxUsers, room, bookedUsers})
    : id = id ?? '',
      gymId = gymId ?? 'Gym ID',
      activityId = activityId ?? 'Activity ID',
      startTime = startTime ?? DateTime.now(),
      endTime = endTime ?? DateTime.now(),
      maxUsers = maxUsers ?? 0,
      room = room ?? 'Room',
      bookedUsers = bookedUsers ?? [];

  factory Slot.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Slot(
      id: snapshot.id,
      gymId: data['gymId'],
      activityId: data['activityId'],
      startTime: data['startTime']?.toDate(),
      endTime: data['endTime']?.toDate(),
      maxUsers: data['maxUsers'],
      room: data['room'],
      bookedUsers: List<String>.from(data['bookedUsers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'gymId': gymId,
      'activityId': activityId,
      'maxUsers': maxUsers,
      'room': room,
      'bookedUsers': bookedUsers,
    };
  }

  Slot copyWith({
    String? id,
    String? gymId,
    String? activityId,
    DateTime? startTime,
    DateTime? endTime,
    int? maxUsers,
    String? room,
    List<String>? bookedUsers,
  }) {
    return Slot(
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      activityId: activityId ?? this.activityId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxUsers: maxUsers ?? this.maxUsers,
      room: room ?? this.room,
      bookedUsers: bookedUsers ?? this.bookedUsers,
    );
  }
}
