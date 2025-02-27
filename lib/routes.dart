import 'package:dima_project/content/app_scaffold.dart';
import 'package:dima_project/content/profile/login/login.dart';
import 'package:flutter/material.dart';

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  // Add here the routes handled by the app
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => AppScaffold());
    case '/login':
      return MaterialPageRoute(builder: (_) => Login());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(body: Center(child: Text("404 Not Found"))),
      );
  }
}
