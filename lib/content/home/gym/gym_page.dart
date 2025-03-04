import 'package:dima_project/content/custom_appbar.dart';
import 'package:flutter/material.dart';

class GymPage extends StatelessWidget {
  const GymPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: create gym page
    return Scaffold(
      appBar: CustomAppBar(title: "Gym"),
      body: Center(child: Text('Welcome to the Gym!')),
    );
  }
}
