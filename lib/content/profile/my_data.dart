import 'package:dima_project/content/profile/new_my_data.dart';
import 'package:flutter/material.dart';
import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_provider.dart';
import 'package:provider/provider.dart';

class MyData extends StatelessWidget {
  final User? user;
  const MyData({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final User? user = context.watch<UserProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text('I miei dati'), elevation: 0),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(
                        Icons.person,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                      title: Text('Nome', style: TextStyle(fontSize: 16)),
                      subtitle: Text(
                        user.displayName.isNotEmpty
                            ? user.displayName
                            : 'Non specificato',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Color.fromARGB(255, 172, 172, 172),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                      leading: Icon(
                        Icons.email,
                        color: Colors.grey[700],
                        size: 22,
                      ),
                      title: Text('Email', style: TextStyle(fontSize: 16)),
                      subtitle: Text(
                        user.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Color.fromARGB(255, 172, 172, 172),
                    ),
                    if (!(user.isAdmin)) ...[
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(
                          Icons.phone,
                          color: Colors.grey[700],
                          size: 22,
                        ),
                        title: Text('Telefono', style: TextStyle(fontSize: 16)),
                        subtitle: Text(
                          user.phoneNumber.isNotEmpty
                              ? user.phoneNumber
                              : 'Non specificato',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 172, 172, 172),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(
                          Icons.home,
                          color: Colors.grey[700],
                          size: 22,
                        ),
                        title: Text(
                          'Indirizzo',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          user.address.isNotEmpty
                              ? user.address
                              : 'Non specificato',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 172, 172, 172),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(
                          Icons.badge,
                          color: Colors.grey[700],
                          size: 22,
                        ),
                        title: Text(
                          'Codice fiscale',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          user.taxCode.isNotEmpty
                              ? user.taxCode
                              : 'Non specificato',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 172, 172, 172),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(
                          Icons.calendar_today,
                          color: Colors.grey[700],
                          size: 22,
                        ),
                        title: Text(
                          'Data di nascita',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          user.birthDate != null
                              ? '${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}'
                              : 'Non specificato',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: Color.fromARGB(255, 172, 172, 172),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                        leading: Icon(
                          Icons.location_city,
                          color: Colors.grey[700],
                          size: 22,
                        ),
                        title: Text(
                          'Luogo di nascita',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          user.birthPlace.isNotEmpty
                              ? user.birthPlace
                              : 'Non specificato',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewMyData(user: user),
                                ),
                              );
                            },
                            child: Text(
                              'Modifica',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
