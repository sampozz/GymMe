import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

class SlotProvider extends ChangeNotifier {
  final SlotService _slotService;
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
    required this.gymId,
    required this.activityId,
  }) : _slotService = slotService ?? SlotService();

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

  /// Books a slot for the current user
  Future<bool> addUserToSlot(Slot slot) async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    // Check if the user is already booked for this slot
    if (slot.bookedUsers.contains(user.uid)) {
      return false; // User is already booked for this slot
    }
    // Check if the number of booked users is less than the max number of users
    if (slot.bookedUsers.length >= slot.maxUsers) {
      return false; // Slot is already fully booked
    }
    // Add the user to the booked users list
    slot.bookedUsers.add(user.uid);
    await _slotService.updateSlot(slot);
    notifyListeners();
    return true; // Booking successful
  }

  /// Create a new slot
  Future<void> createSlot(Slot slot, String recurrence, DateTime? until) async {
    // Always create the initial slot first
    await _slotService.createSlot(slot);

    if (recurrence != 'None' && until != null) {
      DateTime currentDate = slot.startTime!;

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
              hours: slot.endTime!.hour - slot.startTime!.hour,
              minutes: slot.endTime!.minute - slot.startTime!.minute,
            ),
          ),
        );

        await _slotService.createSlot(newSlot);
      }
    }

    _nextSlots = null;
    notifyListeners();
  }

  /// Removes a user from a slot
  Future<void> removeUserFromSlot(String slotId) async {
    auth.User user = auth.FirebaseAuth.instance.currentUser!;
    if (_nextSlots == null) {
      await getUpcomingSlots();
    }
    Slot? slot = _nextSlots!.firstWhere(
      (s) => s.id == slotId,
      orElse: () => Slot(id: '-1'),
    );
    if (slot.id == '-1') {
      return;
    }
    slot.bookedUsers.remove(user.uid);
    await _slotService.updateSlot(slot);
    notifyListeners();
  }
}
