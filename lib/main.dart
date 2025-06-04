import 'package:dima_project/intro/intro_animation.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:dima_project/theme/theme.dart';
import 'package:dima_project/theme/theme_utility.dart';
import 'package:dima_project/global_providers/theme_provider.dart';
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
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Lato");
    MaterialTheme theme = MaterialTheme(textTheme);

    // Usa il tema in base allo stato in ThemeProvider
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'GymMe',
      theme: themeProvider.isDarkMode ? theme.dark() : theme.light(),
      home: const IntroAnimation(),
      // TODO: Add splash screen
      initialRoute: '/',
    );
  }
}
