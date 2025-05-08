import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/home/gym/activity/activity_model.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_model.dart';
import 'package:dima_project/content/home/gym/gym_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConfirmBookingModal extends StatefulWidget {
  final Gym gym;
  final Activity activity;
  final Slot slot;
  final Function onBookingConfirmed;

  const ConfirmBookingModal({
    super.key,
    required this.gym,
    required this.activity,
    required this.slot,
    required this.onBookingConfirmed,
  });

  @override
  State<ConfirmBookingModal> createState() => _ConfirmBookingModalState();
}

class _ConfirmBookingModalState extends State<ConfirmBookingModal> {
  bool _isBookingConfirmed = false;
  bool _confirmationLoading = false;

  void _confirmBooking() async {
    setState(() {
      _confirmationLoading = true;
    });

    bool res = await Provider.of<BookingsProvider>(
      context,
      listen: false,
    ).createBooking(widget.gym, widget.activity, widget.slot);

    if (res) {
      widget.onBookingConfirmed(widget.slot.id);
    }

    setState(() {
      _confirmationLoading = false;
      _isBookingConfirmed = res;
    });
  }

  Widget _buildBookingDetails() {
    String date = DateFormat(
      DateFormat.ABBR_MONTH_WEEKDAY_DAY,
    ).format(widget.slot.startTime);
    String startTime = DateFormat('jm').format(widget.slot.startTime);
    String endTime = DateFormat('jm').format(widget.slot.endTime);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: double.infinity),
          Text(
            widget.activity.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(widget.slot.room, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          Text(date),
          Text(
            '$startTime - $endTime',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Payment at the gym ${widget.activity.price} €',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),
          if (_confirmationLoading)
            const CircularProgressIndicator()
          else if (_isBookingConfirmed && !_confirmationLoading)
            Icon(
              Icons.check_circle_outline_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 40,
            )
          else
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                child: const Text('Confirm'),
                onPressed: () => _confirmBooking(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle at the top for better UX
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content that determines the height
          _buildBookingDetails(),
        ],
      ),
    );
  }
}
