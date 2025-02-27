import 'package:dima_project/content/custom_appbar.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  void _signIn(BuildContext context) async {
    // Sign in with test user
    // TODO: signin with email and password provided as parameters from a form
    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).signIn("test@test.test", "hellas");

    // Redirect to home screen
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement login screen
    return Scaffold(
      appBar: CustomAppBar(title: "Login"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logging in with test user, press login to continue"),
            ElevatedButton(
              onPressed: () => _signIn(context),
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
