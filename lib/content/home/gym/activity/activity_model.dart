class Activity {
  String? id;
  String name;

  Activity({this.id = '', this.name = ''});

  factory Activity.fromFirestore(Map<String, dynamic> data) {
    return Activity(id: data['id'], name: data['name']);
  }

  Map<String, dynamic> toFirestore() {
    return {if (id != null) 'id': id, 'name': name};
  }

  Activity copyWith({String? name}) {
    return Activity(id: id, name: name ?? this.name);
  }
}
