import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyData extends StatelessWidget {
  const MyData({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;
    final List<String> fields = <String>[
      "Nome",
      "Cognome",
      "Email",
      "Telefono",
      "Data di nascita",
      "Luogo di nascita",
      "Indirizzo",
      "Codice fiscale",
    ];

    return Center(child: CircularProgressIndicator());
  }
}
