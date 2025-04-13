import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmBookingModal extends StatefulWidget {
  final Gym gym;
  final Activity activity;
  final Slot slot;

  const ConfirmBookingModal({
    super.key,
    required this.gym,
    required this.activity,
    required this.slot,
  });

  @override
  State<ConfirmBookingModal> createState() => _ConfirmBookingModalState();
}

class _ConfirmBookingModalState extends State<ConfirmBookingModal> {
  bool _isBookingConfirmed = false;

  void _confirmBooking() async {
    bool success = await Provider.of<SlotProvider>(
      context,
      listen: false,
    ).addUserToSlot(widget.slot);

    if (!success) {
      return;
    }

    if (!mounted) return;

    await Provider.of<BookingsProvider>(
      context,
      listen: false,
    ).createBooking(widget.gym, widget.activity, widget.slot);

    if (!mounted) return;

    setState(() {
      _isBookingConfirmed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Center(
        child:
            _isBookingConfirmed
                ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // TODO: customize the modal with more information
                    const Text('Booking confirmed'),
                    ElevatedButton(
                      // TODO: add addToCalendar function
                      child: const Text('Close'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                )
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // TODO: customize the modal with more information
                    const Text('Confirm booking'),
                    ElevatedButton(
                      child: const Text('Confirm'),
                      onPressed: () => _confirmBooking(),
                    ),
                  ],
                ),
      ),
    );
  }
}
