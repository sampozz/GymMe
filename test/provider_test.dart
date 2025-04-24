import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([MockSpec<BookingsProvider>(), MockSpec<ScreenProvider>()])
void main() {
  // Method to set up the test environment
  // Run: flutter pub run build_runner build --delete-conflicting-outputs
}
