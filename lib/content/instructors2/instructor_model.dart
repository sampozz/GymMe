import 'package:cloud_firestore/cloud_firestore.dart';

class Instructor {
  String? id;
  String name;
  String photo;
  String title;

  Instructor({
    this.id = '',
    this.name = '',
    this.photo = '',
    this.title = 'Title not available',
  });

  factory Instructor.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    var data = snapshot.data()!;
    return Instructor(
      id: snapshot.id,
      name: data['name'] ?? Instructor().name,
      photo: data['photo'] ?? Instructor().photo,
      title: data['title'] ?? Instructor().title,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name, 'photo': photo, 'title': title};
  }

  Instructor copyWith({
    String? id,
    String? name,
    String? photo,
    String? title,
  }) {
    return Instructor(
      id: id ?? this.id,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      title: title ?? this.title,
    );
  }
}
