import 'package:dima_project/content/instructors/instructor_model.dart';

class Activity {
  String? id;
  String? title;
  String? description;
  double? price;
  String? instructorId;

  Activity({
    this.id = '',
    this.title = '',
    this.description = 'Description not available',
    this.price = 0.0,
    this.instructorId = '',
  });

  factory Activity.fromFirestore(Map<String, dynamic> data) {
    return Activity(
      id: data['id'],
      title: data['title'] ?? Activity().title,
      description: data['description'] ?? Activity().description,
      price: double.tryParse(['price'].toString()) ?? Activity().price,
      instructorId: data['instructorId'] ?? Instructor().id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
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
