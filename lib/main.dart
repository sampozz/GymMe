import 'package:dima_project/auth_gate/auth_gate.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// TODO?? add activities to favourites -> create new activity card that can be shown in the home
// -- > make it a horizontal list of cards in the gym page
// TODO: when an activity is removed, cosa facciamo??
// TODO: introduction screen

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ScreenProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymMe',
      // TODO: Decide App theme

      /*LAVANDA #FFAE94FC RGB: 174 148 252
          MIRTILLO #FF221743 RGB: 34 23 67
          GIALLO #FFFFD73C RGB: 255 255 215 60
          SABBIA #FFFDF7EA RGB: 255 253 247 234 
          ROSA #FFFEACF0
          CORALLO #FFFB5C1C*/
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch:
              Colors.deepPurple, // Base primary swatch (closest to navy)
          accentColor: Color(0xFFFFC107), // Gold as secondary color
          backgroundColor: Color(0xFFFDF7EA), // Light gray background
          cardColor: Color(0xFFFFFFFF), // White surface for cards
          errorColor: Color.fromARGB(255, 142, 76, 76), // Strong red for errors
        ).copyWith(
          primary: Color.fromARGB(255, 34, 23, 67), // deep purple
          secondary: Color(0xFFFDF7EA), // light beige
          tertiary: Color(0xFF4C9AFF), // Lighter Blue for accents
          surface: Color(0xFFF5F5F5), // White surface
          primaryContainer: Color(0xFFFFFFFF), // White for primary container
          error: Color(0xFFD32F2F), // Standard material red for errors
          onPrimary: Color(0xFFFDF7EA), // White text/icons on primary (navy)
          onSecondary: Color.fromARGB(
            255,
            34,
            23,
            67,
          ), // Black text/icons on secondary (gold)
          onTertiary: Colors.white, // White text/icons on lighter blue
          onSurface: Colors.black, // Black text on white surfaces
          onError: Colors.white, // White text on red error color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            elevation: 0,
            fixedSize: Size(200, 40),
            backgroundColor: Colors.white,
          ),
        ),
      ),

      home: const AuthGate(),
      // TODO: Add splash screen
      initialRoute: '/',
    );
  }
}
