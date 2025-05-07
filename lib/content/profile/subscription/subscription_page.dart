import 'package:dima_project/content/bookings/widgets/booking_page.dart';
import 'package:dima_project/content/bookings/widgets/bookings.dart';
import 'package:dima_project/content/profile/my_data.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Subscription extends StatelessWidget {
  final User? user;
  const Subscription({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text('Tessere e abbonamenti'), elevation: 0),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : Text('Prova'),
    );
  }
}
