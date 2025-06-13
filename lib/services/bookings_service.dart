import 'dart:convert';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gymme/models/booking_model.dart';
import 'package:gymme/models/booking_update_model.dart';
import 'package:gymme/models/slot_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
      }

      transaction.set(bookingRef, booking);
      return bookingRef.id;
    });
  }

  /// Deletes a booking by ID
  Future<void> deleteBooking(Booking booking) async {
    await firestore.runTransaction((transaction) async {
      final bookingRef = firestore.collection('booking').doc(booking.id);
      final slotRef = firestore.collection('slot').doc(booking.slotId);

      final slot = await transaction.get(slotRef);
      final b = await transaction.get(bookingRef);

      if (slot.exists) {
        transaction.update(slotRef, {
          'bookedUsers': FieldValue.arrayRemove([booking.userId]),
        });
      }

      if (b.exists) {
        transaction.delete(bookingRef);
      }
    });
  }

  Future<void> markUpdateAsRead(BookingUpdate bookingUpdate) async {
    await firestore.collection('booking').doc(bookingUpdate.bookingId).update({
      'bookingUpdate': bookingUpdate.toFirestore(),
    });
  }

  void addToCalendarWeb(String url) {
    launchUrl(Uri.parse(url));
  }

  void addToCalendarMobile(Event event) {
    Add2Calendar.addEvent2Cal(event);
  }

  Future<void> goToPayment(Booking booking) async {
    final String projectId = 'dima-app-ea636';
    final String functionUrl =
        'https://us-central1-$projectId.cloudfunctions.net/createCheckout';

    final Uri uri = Uri.parse(functionUrl).replace(
      queryParameters: {
        'amount': (booking.price * 100).toString(),
        'bookingId': booking.id,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['url'] != null) {
        await launchUrl(Uri.parse(data['url']));
      }
    }
  }

  Future<void> confirmPayment(String bookingId) async {
    await firestore.collection('booking').doc(bookingId).update({
      'paymentStatus': 'completed',
    });
  }
}
