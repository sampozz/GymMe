import 'package:dima_project/content/gym/gym_service.dart';
import 'package:flutter/material.dart';

class GymProvider with ChangeNotifier {
  final GymService _gymService;

  // Dependency injection, needed for unit testing
  GymProvider({GymService? gymService})
    : _gymService = gymService ?? GymService();

  // TODO: implement gym provider
}
