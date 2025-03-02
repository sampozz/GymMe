import 'package:dima_project/content/home/home.dart';
import 'package:dima_project/content/login/login.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  User? user = FirebaseAuth.instance.currentUser;

  // Add here the routes handled by the app
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => Home());
    case '/login':
      return MaterialPageRoute(builder: (_) => Login());
    case '/profile':
      // Profile screen is only accessible if user is logged in, otherwise redirect to login
      return MaterialPageRoute(
        builder: (_) => user != null ? ProfileScreen() : Login(),
      );
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(body: Center(child: Text("404 Not Found"))),
      );
  }
}
