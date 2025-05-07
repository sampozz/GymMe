class BookingUpdate {
  final DateTime updatedAt;
  final String message;
  bool read;
  final String bookingId;

  BookingUpdate({updatedAt, message, read, bookingId})
    : updatedAt = updatedAt ?? DateTime.now(),
      message = message ?? 'Booking updated',
      read = read ?? false,
      bookingId = bookingId ?? '';

  factory BookingUpdate.fromFirestore(Map<String, dynamic> data, String? id) {
    return BookingUpdate(
      updatedAt: data['updatedAt']?.toDate(),
      message: data['message'],
      read: data['read'],
      bookingId: id,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'updatedAt': updatedAt,
      'message': message,
      'read': read,
      'bookingId': bookingId,
    };
  }
}
