import 'package:dima_project/providers/bookings_provider.dart';
import 'package:dima_project/providers/slot_provider.dart';
import 'package:dima_project/providers/instructor_provider.dart';
import 'package:dima_project/providers/gym_provider.dart';
import 'package:dima_project/providers/map_provider.dart';
import 'package:dima_project/providers/screen_provider.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<BookingsProvider>(),
  MockSpec<ScreenProvider>(),
  MockSpec<UserProvider>(),
  MockSpec<GymProvider>(),
  MockSpec<InstructorProvider>(),
  MockSpec<SlotProvider>(),
  MockSpec<PlatformService>(),
  MockSpec<MapProvider>(),
  MockSpec<Position>(),
])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
