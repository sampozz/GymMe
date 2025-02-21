import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.read<UserProvider>().user;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(user != null ? "Welcome, ${user.userName}" : "Welcome, Guest"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (user == null) {
                Navigator.pushNamed(context, '/login');
              } else {
                Navigator.pushNamed(context, '/profile');
              }
            },
            child: Text(user == null ? "Login" : "Go to Profile"),
          ),
        ],
      ),
    );
  }
}
