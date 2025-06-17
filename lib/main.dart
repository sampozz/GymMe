import 'package:gymme/content/stripe_success_page.dart';
import 'package:gymme/intro/intro_animation.dart';
import 'package:gymme/auth_gate/auth_gate.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/providers/screen_provider.dart';
import 'package:gymme/providers/user_provider.dart';
import 'package:gymme/theme/theme.dart';
import 'package:gymme/theme/theme_utility.dart';
import 'package:gymme/providers/theme_provider.dart';
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

  Route<dynamic>? generateStripeRoute(settings) {
    Uri uri = Uri.parse(settings.name ?? '');
    if (uri.path == '/stripesuccess') {
      final bookingId = uri.queryParameters['bookingId'] ?? '';
      return MaterialPageRoute(
        builder:
            (_) => ChangeNotifierProvider(
              create: (_) => BookingsProvider(),
              child: StripeSuccessPage(bookingId: bookingId),
            ),
      );
    }
    return null;
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
          onGenerateRoute: generateStripeRoute,
        );
      },
    );
  }
}
