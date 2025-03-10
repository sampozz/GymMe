class Activity {
  String id;
  String name;

  Activity({this.id = '', this.name = ''});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] ?? Activity().id,
      name: json['name'] ?? Activity().name,
    );
  }
}
