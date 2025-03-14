import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String id;
  String title;
  String description;
  DateTime? dateTime;
  int duration;
  String userId;
  String gymId;

  Booking({
    this.id = '',
    this.title = '',
    this.description = '',
    this.dateTime,
    this.duration = 0,
    this.userId = '',
    this.gymId = '',
  });

  factory Booking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Booking(
      id: snapshot.id,
      title: data['title'] ?? Booking().title,
      description: data['description'] ?? Booking().description,
      dateTime: data['date']?.toDate() ?? Booking().dateTime,
      duration: data['duration'] ?? Booking().duration,
      userId: data['userId'] ?? Booking().userId,
      gymId: data['gymId'] ?? Booking().gymId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'date': dateTime,
      'duration': duration,
      'userId': userId,
      'gymId': gymId,
    };
  }
}
