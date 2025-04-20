import 'package:dima_project/content/instructors/instructor_model.dart';

class Activity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String instructorId;

  Activity({id, title, description, price, instructorId})
    : id = id ?? '',
      title = title ?? 'Activity',
      description = description ?? 'Description',
      price = price ?? 0.0,
      instructorId = instructorId ?? Instructor().id;

  factory Activity.fromFirestore(Map<String, dynamic> data) {
    return Activity(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      price: double.tryParse(data['price'].toString()),
      instructorId: data['instructorId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'instructorId': instructorId,
    };
  }

  Activity copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? instructorId,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      instructorId: instructorId ?? this.instructorId,
    );
  }
}
