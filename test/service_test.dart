import 'dart:io';

import 'package:gymme/services/bookings_service.dart';
import 'package:gymme/services/slot_service.dart';
import 'package:gymme/services/gym_service.dart';
import 'package:gymme/services/instructor_service.dart';
import 'package:gymme/content/map/map_service.dart';
import 'package:gymme/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<BookingsService>(),
  MockSpec<GymService>(),
  MockSpec<UserService>(),
  MockSpec<InstructorService>(),
  MockSpec<SlotService>(),
  MockSpec<http.Client>(),
  MockSpec<MapService>(),
  MockSpec<GoogleMapController>(),
  MockSpec<HttpClient>(),
])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
