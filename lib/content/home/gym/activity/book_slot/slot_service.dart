import 'package:cloud_firestore/cloud_firestore.dart';
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
              .where('start', isGreaterThanOrEqualTo: date)
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
}
