import 'package:dima_project/intro/intro_animation.dart';
import 'package:dima_project/auth_gate/auth_gate.dart';
import 'package:dima_project/providers/screen_provider.dart';
import 'package:dima_project/providers/user_provider.dart';
import 'package:dima_project/theme/theme.dart';
import 'package:dima_project/theme/theme_utility.dart';
import 'package:dima_project/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

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

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final themeProvider = context.read<ThemeProvider>();
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    themeProvider.updateSystemTheme(systemBrightness);
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = createTextTheme(context, "Lato");
    MaterialTheme theme = MaterialTheme(textTheme);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'GymMe',
          theme: themeProvider.isDarkMode ? theme.dark() : theme.light(),
          home: kIsWeb ? const AuthGate() : const IntroAnimation(),
          initialRoute: '/',
        );
      },
    );
  }
}
