import 'package:flutter/material.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:provider/provider.dart';

class StripeSuccessPage extends StatelessWidget {
  final String bookingId;

  const StripeSuccessPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    context.read<BookingsProvider>().confirmPayment(bookingId);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Successful')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 80),
            SizedBox(height: 24),
            Text(
              'Your payment was successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
