import 'package:dima_project/content/app_scaffold.dart';
import 'package:dima_project/content/bookings/bookings_provider.dart';
import 'package:dima_project/content/instructors/instructor_provider.dart';
import 'package:dima_project/content/profile/login/login.dart';
import 'package:dima_project/global_providers/gym_provider.dart';
import 'package:dima_project/global_providers/map_provider.dart';
import 'package:dima_project/global_providers/screen_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Login();
        }

        return MultiProvider(
          providers: [
            // List of global providers (accessible to all widgets)
            ChangeNotifierProvider(create: (context) => ScreenProvider()),
            ChangeNotifierProvider(create: (context) => GymProvider()),
            ChangeNotifierProvider(create: (context) => BookingsProvider()),
            ChangeNotifierProvider(create: (context) => InstructorProvider()),
            ChangeNotifierProvider(create: (context) => MapProvider()),
          ],
          // Root app
          child: const AppScaffold(),
        );
      },
    );
  }
}
