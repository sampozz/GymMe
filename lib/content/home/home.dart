import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;

    return Scaffold(
      // TODO: Implement home screen
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user != null ? "Welcome, ${user.email}" : "Welcome, Guest"),
            if (user == null)
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text("Login"),
              ),
          ],
        ),
      ),
    );
  }
}
