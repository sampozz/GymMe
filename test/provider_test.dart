import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/home/gym/activity/book_slot/slot_provider.dart';
import 'package:dima_project/content/instructors/instructor_provider.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<BookingsProvider>(),
  MockSpec<ScreenProvider>(),
  MockSpec<UserProvider>(),
  MockSpec<GymProvider>(),
  MockSpec<InstructorProvider>(),
  MockSpec<SlotProvider>(),
  MockSpec<PlatformService>(),
])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
