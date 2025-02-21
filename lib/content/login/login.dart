import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  Future<void> _signIn(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "test@test.test",
        password: "testicolo",
      );

      if (!context.mounted) return;

      await Provider.of<UserProvider>(context, listen: false).getUser();

      if (!context.mounted) return;

      Navigator.pushReplacementNamed(context, '/'); // Redirect after login
    } catch (e) {
      // ...
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Logging in with test user, press login to continue"),
            SizedBox(height: 20),
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
