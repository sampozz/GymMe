class Subscription {
  final String id;
  final String title;
  final String description;
  final DateTime? startTime;
  final DateTime? expiryDate;
  final double price;
  final DateTime? paymentDate;
  final int duration;

  Subscription({
    id,
    title,
    description,
    startTime,
    expiryDate,
    price,
    gymId,
    paymentDate,
    duration,
  }) : id = id ?? '',
       title = title ?? 'Subscription',
       description = description ?? 'Description',
       startTime = startTime ?? DateTime.now(),
       expiryDate = expiryDate ?? DateTime.now(),
       price = price ?? 0.0,
       paymentDate = expiryDate ?? DateTime.now(),
       duration = duration ?? 0;

  factory Subscription.fromFirestore(Map<String, dynamic> data) {
    return Subscription(
      id: data['id'],
      title: data['title'],
      description: data['description'],
      startTime: data['startTime']?.toDate(),
      expiryDate: data['expiryDate']?.toDate(),
      price: double.tryParse(data['price'].toString()),
      paymentDate: data['paymentDate']?.toDate(),
      duration: data['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime,
      'expiryDate': expiryDate,
      'price': price,
      'paymentDate': paymentDate,
      'duration': duration,
    };
  }
}
