import 'package:dima_project/auth_gate/auth_gate.dart';
import 'package:dima_project/content/instructors/instructor_provider.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:dima_project/global_providers/map_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// TODO: add to calendar
// TODO: favourites page
// TODO?? add activities to favourites -> create new activity card that can be shown in the home
// -- > make it a horizontal list of cards in the gym page
// TODO: customize modal to confirm booking with all the data
// TODO: add options in the confirm modal for the admin to modify the slot
// TODO: add options in the confirm modal for the admin to delete the slot
// TODO: in the calendar tabs show a flag if a slot is available
// TODO: when an activity is removed, cosa facciamo??
// TODO: notifications
// TODO: login and register
// TODO: introduction screen

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // List of global providers (accessible to all widgets)
        ChangeNotifierProvider(create: (context) => ScreenProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => GymProvider()),
        ChangeNotifierProvider(create: (context) => BookingsProvider()),
        ChangeNotifierProvider(create: (context) => InstructorProvider()),
        ChangeNotifierProvider(create: (context) => MapProvider()),
      ],
      // Root app
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // TODO: Decide App name
      title: 'Flutter Demo',
      // TODO: Decide App theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue, // Base primary swatch (closest to navy)
          accentColor: Color(0xFFFFC107), // Gold as secondary color
          backgroundColor: Color(0xFFF5F5F5), // Light gray background
          cardColor: Color(0xFFFFFFFF), // White surface for cards
          errorColor: Color(0xFFD32F2F), // Strong red for errors
        ).copyWith(
          primary: Color(0xFF000080), // Navy Blue (custom primary)
          secondary: Color(0xFFFFC107), // Gold (custom secondary)
          tertiary: Color(0xFF4C9AFF), // Lighter Blue for accents
          surface: Color(0xFFF5F5F5), // White surface
          primaryContainer: Color(0xFFFFFFFF), // White for primary container
          error: Color(0xFFD32F2F), // Standard material red for errors
          onPrimary: Colors.white, // White text/icons on primary (navy)
          onSecondary: Colors.black, // Black text/icons on secondary (gold)
          onTertiary: Colors.white, // White text/icons on lighter blue
          onSurface: Colors.black, // Black text on white surfaces
          onError: Colors.white, // White text on red error color
        ),
      ),
      home: const AuthGate(),
      // TODO: Add splash screen
      initialRoute: '/',
    );
  }
}
