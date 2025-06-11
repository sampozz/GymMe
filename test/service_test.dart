import 'package:dima_project/services/bookings_service.dart';
import 'package:dima_project/services/slot_service.dart';
import 'package:dima_project/services/gym_service.dart';
import 'package:dima_project/services/instructor_service.dart';
import 'package:dima_project/content/map/map_service.dart';
import 'package:dima_project/services/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<BookingsService>(),
  MockSpec<GymService>(),
  MockSpec<UserService>(),
  MockSpec<InstructorService>(),
  MockSpec<SlotService>(),
  MockSpec<http.Client>(),
  MockSpec<MapService>(),
])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
