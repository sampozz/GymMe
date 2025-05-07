import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/bookings/booking_model.dart';
import 'package:dima_project/content/bookings/booking_update_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class BookingsService {
  final FirebaseFirestore firestore;
  final auth.FirebaseAuth firebaseAuth;

  BookingsService({
    FirebaseFirestore? firestore,
    auth.FirebaseAuth? firebaseAuth,
  }) : firestore = firestore ?? FirebaseFirestore.instance,
       firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  /// Fetches the bookings for the current user
  /// Returns a list of bookings
  Future<List<Booking>> fetchBookings() async {
    List<Booking> bookings = [];
    try {
      String uid = firebaseAuth.currentUser!.uid;
      var snapshot =
          await firestore
              .collection('booking')
              .where('userId', isEqualTo: uid)
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

  /// Add the booking to the booking collection and update the slot collection
  Future<String?> addBooking(Booking booking, Slot slot) async {
    return await firestore.runTransaction((transaction) async {
      final bookingRef =
          firestore
              .collection('booking')
              .withConverter(
                fromFirestore: Booking.fromFirestore,
                toFirestore: (booking, options) => booking.toFirestore(),
              )
              .doc();
      final slotRef = firestore.collection('slot').doc(slot.id);
      final slotDoc = await transaction.get(slotRef);

      if (slotDoc.exists) {
        transaction.update(slotRef, {
          'bookedUsers': FieldValue.arrayUnion([booking.userId]),
        });
      } else {
        throw Exception("Slot does not exist");
      }

      transaction.set(bookingRef, booking);
      return bookingRef.id;
    });
  }

  /// Deletes a booking by ID
  Future<void> deleteBooking(Booking booking) async {
    firestore.runTransaction((transaction) async {
      try {
        final bookingRef = firestore.collection('booking').doc(booking.id);
        final slotRef = firestore.collection('slot').doc(booking.slotId);

        final slot = await transaction.get(slotRef);
        final b = await transaction.get(bookingRef);

        if (slot.exists) {
          transaction.update(slotRef, {
            'bookedUsers': FieldValue.arrayRemove([booking.userId]),
          });
        } else {
          throw Exception("Slot does not exist");
        }

        if (b.exists) {
          transaction.delete(bookingRef);
        } else {
          throw Exception("Booking does not exist");
        }
      } catch (e) {
        // TODO: handle error
        print(e);
        rethrow;
      }
    });
  }

  Future<void> markUpdateAsRead(BookingUpdate bookingUpdate) async {
    try {
      firestore.collection('booking').doc(bookingUpdate.bookingId).update({
        'bookingUpdate': bookingUpdate.toFirestore(),
      });
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }
}
