import 'package:cloud_firestore/cloud_firestore.dart';

class Slot {
  final String id;
  final String gymId;
  final String activityId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int maxUsers;
  final String room;
  final List<String> bookedUsers;

  Slot({
    this.id = '',
    this.gymId = '',
    this.activityId = '',
    this.startTime,
    this.endTime,
    this.maxUsers = 0,
    this.room = 'Room not available',
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
      startTime: data['startTime']?.toDate() ?? DateTime(1971, 1, 1),
      endTime: data['endTime']?.toDate() ?? DateTime(1971, 1, 1),
      maxUsers: data['maxUsers'] ?? Slot().maxUsers,
      room: data['room'] ?? Slot().room,
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
