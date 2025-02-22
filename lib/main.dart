import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:dima_project/routes.dart';
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
        // List of global providers (accessible to all widgets)
        ChangeNotifierProvider(create: (context) => ScreenProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      onGenerateRoute: onGenerateRoute,
      initialRoute: '/',
    );
  }
}
