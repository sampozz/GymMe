import 'package:gymme/models/slot_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SlotCard extends StatelessWidget {
  final Slot slot;
  final bool alreadyBooked;

  const SlotCard({super.key, required this.slot, this.alreadyBooked = false});

  @override
  Widget build(BuildContext context) {
    String day = DateFormat(
      DateFormat.ABBR_MONTH_WEEKDAY_DAY,
    ).format(slot.startTime);
    String startTime = DateFormat.jm().format(slot.startTime);
    String endTime = DateFormat.jm().format(slot.endTime);
    int bookedUsers = slot.bookedUsers.length;

    return MouseRegion(
      cursor:
          alreadyBooked ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: Card(
        color: alreadyBooked ? Colors.grey[50] : Colors.white,
        elevation: 0,
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day, style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$startTime - $endTime'),
                    const SizedBox(height: 4),
                    Text(
                      'Room: ${slot.room}',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '$bookedUsers / ${slot.maxUsers}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            bookedUsers >= slot.maxUsers
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                    Text('bookings'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
