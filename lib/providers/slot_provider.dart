import 'package:gymme/models/slot_model.dart';
import 'package:gymme/services/slot_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class SlotProvider extends ChangeNotifier {
  final SlotService _slotService;
  final auth.FirebaseAuth _firebaseAuth;
  final String gymId;
  final String activityId;
  List<Slot>? _nextSlots;

  /// Getter for the next slots. If the list is null, fetch it from the service.
  /// The key is a tuple of gymId and activityId.
  List<Slot>? get nextSlots {
    if (_nextSlots == null) {
      getUpcomingSlots();
    }
    return _nextSlots;
  }

  // Dependency injection, needed for unit testing
  SlotProvider({
    SlotService? slotService,
    auth.FirebaseAuth? firebaseAuth,
    required this.gymId,
    required this.activityId,
  }) : _slotService = slotService ?? SlotService(),
       _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance;

  /// Fetches the next available slots for a given gym and activity.
  Future<List<Slot>> getUpcomingSlots() async {
    final currentDate = DateTime.now();
    final startOfToday = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );
    var slots = await _slotService.fetchUpcomingSlots(
      gymId,
      activityId,
      startOfToday,
    );
    _nextSlots = slots;
    notifyListeners();
    return slots;
  }

  /// Create a new slot
  Future<void> createSlot(Slot slot, String recurrence, DateTime? until) async {
    // Always create the initial slot first
    await _slotService.createSlot(slot);

    if (recurrence != 'None' && until != null) {
      DateTime currentDate = slot.startTime;

      while (true) {
        // Update the date for the next occurrence
        if (recurrence == 'Daily') {
          currentDate = currentDate.add(Duration(days: 1));
        } else if (recurrence == 'Weekly') {
          currentDate = currentDate.add(Duration(days: 7));
        } else if (recurrence == 'Monthly') {
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
            currentDate.hour,
            currentDate.minute,
          );
        }

        // Check if we've gone past the end date
        if (!currentDate.isBefore(until.add(Duration(days: 1)))) {
          break;
        }

        // Create a new slot with the updated date
        Slot newSlot = slot.copyWith(
          startTime: currentDate,
          endTime: currentDate.add(
            Duration(
              hours: slot.endTime.hour - slot.startTime.hour,
              minutes: slot.endTime.minute - slot.startTime.minute,
            ),
          ),
        );

        await _slotService.createSlot(newSlot);
      }
    }

    _nextSlots = null;
    notifyListeners();
  }

  /// Update an existing slot in firebase
  /// Deletes the list of next slots to force a refresh
  Future<void> updateSlot(Slot slot) async {
    await _slotService.updateSlot(slot);
    _nextSlots = null;
    notifyListeners();
  }

  /// Add the user to the booked users list of a slot
  /// No need to update the slot in firebase, as it is done in the transaction in booking service
  Future<void> addUserToSlot(String slotId) async {
    auth.User user = _firebaseAuth.currentUser!;
    // Get the slot from the list of next slots
    int index = _nextSlots!.indexWhere((slot) => slot.id == slotId);
    if (index == -1) {
      return;
    }
    _nextSlots![index].bookedUsers.add(user.uid);
    notifyListeners();
  }

  Future<void> deleteSlot(String slotId) async {
    await _slotService.deleteSlot(slotId);
    _nextSlots = null;
    notifyListeners();
  }
}
