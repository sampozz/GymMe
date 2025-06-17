import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gymme/content/app_scaffold.dart';
import 'package:gymme/providers/bookings_provider.dart';
import 'package:gymme/providers/instructor_provider.dart';
import 'package:gymme/content/login/login.dart';
import 'package:gymme/providers/gym_provider.dart';
import 'package:gymme/providers/map_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) {
      setState(() {
        _isConnected =
            result.contains(ConnectivityResult.mobile) ||
            result.contains(ConnectivityResult.wifi) ||
            result.contains(ConnectivityResult.ethernet);
      });
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected =
          results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.ethernet);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!_isConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No internet connection. Please check your network.',
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true,
              ),
            );
          });
        }

        if (!snapshot.hasData) {
          return Login();
        }

        return MultiProvider(
          providers: [
            // List of global providers (accessible to all widgets)
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
