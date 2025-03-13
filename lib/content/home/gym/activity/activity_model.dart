class Activity {
  String id;
  String name;

  Activity({this.id = '', this.name = ''});

  factory Activity.fromFirestore(Map<String, dynamic> data) {
    return Activity(id: data['id'], name: data['name']);
  }

  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}
