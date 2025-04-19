import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  String? id;
  String title;
  String description;
  DateTime? startTime;
  DateTime? endTime;
  int duration;
  double price;
  String gymName;
  String room;
  String instructorName;
  String instructorPhoto;
  String instructorTitle;
  String userId;
  String gymId;
  String slotId;
  String activityId;

  Booking({
    this.id,
    this.title = '',
    this.description = '',
    this.startTime,
    this.endTime,
    this.duration = 0,
    this.price = 0.0,
    this.gymName = '',
    this.room = '',
    this.instructorName = '',
    this.instructorPhoto = '',
    this.instructorTitle = '',
    this.userId = '',
    this.gymId = '',
    this.slotId = '',
    this.activityId = '',
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
      startTime: data['startTime']?.toDate() ?? DateTime(0),
      endTime: data['endTime']?.toDate() ?? DateTime(0),
      duration: data['duration'] ?? Booking().duration,
      price: double.tryParse(data['price'].toString()) ?? Booking().price,
      gymName: data['gymName'] ?? Booking().gymName,
      room: data['room'] ?? Booking().room,
      instructorName: data['instructorName'] ?? Booking().instructorName,
      instructorPhoto: data['instructorPhoto'] ?? Booking().instructorPhoto,
      instructorTitle: data['instructorTitle'] ?? Booking().instructorTitle,
      userId: data['userId'] ?? Booking().userId,
      gymId: data['gymId'] ?? Booking().gymId,
      slotId: data['slotId'] ?? Booking().slotId,
      activityId: data['activityId'] ?? Booking().activityId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'price': price,
      'gymName': gymName,
      'room': room,
      'instructorName': instructorName,
      'instructorPhoto': instructorPhoto,
      'instructorTitle': instructorTitle,
      'userId': userId,
      'gymId': gymId,
      'slotId': slotId,
      'activityId': activityId,
    };
  }
}
