import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  void _signOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;

    // TODO: implement profile page
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(user != null ? "Welcome, ${user.email}" : "Welcome, Guest"),
          user == null
              ? ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text("Login"),
              )
              : ElevatedButton(
                onPressed: () => _signOut(context),
                child: Text("Logout"),
              ),
        ],
      ),
    );
  }
}
