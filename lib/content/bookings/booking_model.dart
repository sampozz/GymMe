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

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? Booking().id,
      title: json['title'] ?? Booking().title,
      description: json['description'] ?? Booking().description,
      dateTime:
          json['date'] != null
              ? DateTime.parse(json['date'])
              : Booking().dateTime,
      duration: json['duration'] ?? Booking().duration,
      userId: json['userId'] ?? Booking().userId,
      gymId: json['gymId'] ?? Booking().gymId,
    );
  }
}
