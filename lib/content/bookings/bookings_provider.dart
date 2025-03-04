import 'package:dima_project/content/bookings/bookings_service.dart';
import 'package:flutter/material.dart';

class BookingsProvider extends ChangeNotifier {
  BookingsService _bookingsService;

  // Dependency injection, needed for unit testing
  BookingsProvider({BookingsService? bookingsService})
    : _bookingsService = bookingsService ?? BookingsService();

  // TODO: implement bookings provider
}
