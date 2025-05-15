import 'package:dima_project/content/bookings/bookings_service.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_service.dart';
import 'package:dima_project/content/home/gym/gym_service.dart';
import 'package:dima_project/content/instructors/instructor_service.dart';
import 'package:dima_project/global_providers/user/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<BookingsService>(),
  MockSpec<GymService>(),
  MockSpec<UserService>(),
  MockSpec<InstructorService>(),
  MockSpec<SlotService>(),
  MockSpec<http.Client>(),
])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
