import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class BookingsService {
  /// Fetches the bookings for the current user
  /// Returns a list of bookings
  Future<List<Booking>> fetchBookings() async {
    List<Booking> bookings = [];
    try {
      auth.User user = auth.FirebaseAuth.instance.currentUser!;
      var snapshot =
          await FirebaseFirestore.instance
              .collection('bookings')
              .where('userId', isEqualTo: user.uid)
              .withConverter(
                fromFirestore: Booking.fromFirestore,
                toFirestore: (booking, options) => booking.toFirestore(),
              )
              .get();
      bookings = snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
    return bookings;
  }

  /// Books a slot for the current user and returns the booking ID
  Future<String?> addBooking(Booking booking) async {
    try {
      var ref = await FirebaseFirestore.instance
          .collection('bookings')
          .withConverter(
            fromFirestore: Booking.fromFirestore,
            toFirestore: (booking, options) => booking.toFirestore(),
          )
          .add(booking);
      return ref.id;
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }
}
