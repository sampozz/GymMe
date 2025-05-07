import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/bookings/booking_update_model.dart';

class Booking {
  String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final double price;
  final String gymName;
  final String room;
  final String instructorName;
  final String instructorPhoto;
  final String instructorTitle;
  final String userId;
  final String gymId;
  final String slotId;
  final String activityId;
  final BookingUpdate? bookingUpdate;

  Booking({
    id,
    title,
    description,
    startTime,
    endTime,
    duration,
    price,
    gymName,
    room,
    instructorName,
    instructorPhoto,
    instructorTitle,
    userId,
    gymId,
    slotId,
    activityId,
    this.bookingUpdate,
  }) : id = id ?? '',
       title = title ?? 'Booking',
       description = description ?? 'Description',
       startTime = startTime ?? DateTime.now(),
       endTime = endTime ?? DateTime.now(),
       duration = duration ?? 60,
       price = price ?? 0.0,
       gymName = gymName ?? 'Gym Name',
       room = room ?? 'Room',
       instructorName = instructorName ?? 'Instructor Name',
       instructorPhoto = instructorPhoto ?? 'assets/avatar.png',
       instructorTitle = instructorTitle ?? 'Instructor Title',
       userId = userId ?? 'User ID',
       gymId = gymId ?? 'Gym ID',
       slotId = slotId ?? 'Slot ID',
       activityId = activityId ?? 'Activity ID';

  factory Booking.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Booking(
      id: snapshot.id,
      title: data['title'],
      description: data['description'],
      startTime: data['startTime']?.toDate(),
      endTime: data['endTime']?.toDate(),
      duration: data['duration'],
      price: double.tryParse(data['price'].toString()),
      gymName: data['gymName'],
      room: data['room'],
      instructorName: data['instructorName'],
      instructorPhoto: data['instructorPhoto'],
      instructorTitle: data['instructorTitle'],
      userId: data['userId'],
      gymId: data['gymId'],
      slotId: data['slotId'],
      activityId: data['activityId'],
      bookingUpdate:
          data['bookingUpdate'] != null
              ? BookingUpdate.fromFirestore(data['bookingUpdate'], snapshot.id)
              : null,
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
      if (bookingUpdate != null) 'bookingUpdate': bookingUpdate!.toFirestore(),
    };
  }
}
