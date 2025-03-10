import 'package:dima_project/content/app_scaffold.dart';
import 'package:dima_project/content/home/gym/gym_provider.dart';
import 'package:dima_project/content/profile/login/login.dart';
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
            ChangeNotifierProvider(create: (context) => GymProvider()),
            // Add other providers here if needed
          ],
          child: AppScaffold(),
        );
      },
    );
  }
}
