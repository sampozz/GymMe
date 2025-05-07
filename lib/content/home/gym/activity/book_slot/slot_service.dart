import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/content/bookings/booking_update_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';

class SlotService {
  /// Fetches a list of slots from the Firestore 'slots' collection.
  Future<List<Slot>> fetchUpcomingSlots(
    String gymId,
    String activityId,
    DateTime date,
  ) async {
    List<Slot> slots = [];
    try {
      // Get slots from firebase
      var slotRef =
          await FirebaseFirestore.instance
              .collection('slot')
              .withConverter(
                fromFirestore: Slot.fromFirestore,
                toFirestore: (slot, options) => slot.toFirestore(),
              )
              .where('gymId', isEqualTo: gymId)
              .where('activityId', isEqualTo: activityId)
              .where('startTime', isGreaterThanOrEqualTo: date)
              .get();

      for (var doc in slotRef.docs) {
        slots.add(doc.data());
      }
    } catch (e) {
      // TODO: Handle error
      print(e);
    }

    return slots;
  }

  /// Create a new slot
  /// This method is used to create a new slot in the Firestore 'slots' collection.
  Future<void> createSlot(Slot slot) async {
    try {
      await FirebaseFirestore.instance
          .collection('slot')
          .add(slot.toFirestore());
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }

  Future<void> updateSlot(Slot slot) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      try {
        final slotRef = FirebaseFirestore.instance
            .collection('slot')
            .doc(slot.id);
        final bookingsRef = FirebaseFirestore.instance
            .collection('booking')
            .where('slotId', isEqualTo: slot.id);

        final slotDoc = await transaction.get(slotRef);
        final bookingsSnapshot = await bookingsRef.get();

        if (slotDoc.exists) {
          // Update the slot
          transaction.update(slotRef, slot.toFirestore());

          // Update the bookings
          for (var bookingDoc in bookingsSnapshot.docs) {
            transaction.update(bookingDoc.reference, {
              'startTime': slot.startTime,
              'endTime': slot.endTime,
              'room': slot.room,
              'bookingUpdate':
                  BookingUpdate(
                    updatedAt: DateTime.now(),
                    message: 'Your booking has been updated',
                    read: false,
                  ).toFirestore(),
            });
          }
        } else {
          throw Exception("Slot does not exist");
        }
      } catch (e) {
        // TODO: handle error
        print(e);
        rethrow;
      }
    });
  }

  /// Deletes a slot from the Firestore 'slots' collection.
  Future<void> deleteSlot(String slotId) async {
    try {
      await FirebaseFirestore.instance.collection('slot').doc(slotId).delete();
    } catch (e) {
      // TODO: handle error
      print(e);
      rethrow;
    }
  }
}
