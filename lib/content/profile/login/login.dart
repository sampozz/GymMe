import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  void _signIn(BuildContext context, bool isAdmin) async {
    // Sign in with test user
    // TODO: signin with email and password provided as parameters from a form
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).signIn(isAdmin ? "admin@test.test" : "test@test.test", "hellas");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement login screen
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logging in with test user, press login to continue"),
            ElevatedButton(
              onPressed: () => _signIn(context, false),
              child: Text("Login as regular user"),
            ),
            ElevatedButton(
              onPressed: () => _signIn(context, true),
              child: Text("Login as admin user"),
            ),
          ],
        ),
      ),
    );
  }
}
