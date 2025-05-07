class Subscription {
  String id;
  String name;
  DateTime? expiryDate;

  Subscription({this.id = '', this.name = '', this.expiryDate});

  bool get isValid => expiryDate!.isAfter(DateTime.now());
}
