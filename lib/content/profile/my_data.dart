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
      appBar: AppBar(title: Text('My data'), elevation: 0),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          leading: Icon(
                            Icons.person,
                            color: Colors.grey[700],
                            size: 22,
                          ),
                          title: Text('Name', style: TextStyle(fontSize: 16)),
                          subtitle: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName
                                : 'Unspecified',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          leading: Icon(
                            Icons.email,
                            color: Colors.grey[700],
                            size: 22,
                          ),
                          title: Text('Email', style: TextStyle(fontSize: 16)),
                          subtitle: Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (!(user.isAdmin)) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            leading: Icon(
                              Icons.phone,
                              color: Colors.grey[700],
                              size: 22,
                            ),
                            title: Text(
                              'Phone number',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              user.phoneNumber.isNotEmpty
                                  ? user.phoneNumber
                                  : 'Unspecified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            leading: Icon(
                              Icons.home,
                              color: Colors.grey[700],
                              size: 22,
                            ),
                            title: Text(
                              'Address',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              user.address.isNotEmpty
                                  ? user.address
                                  : 'Unspecified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            leading: Icon(
                              Icons.badge,
                              color: Colors.grey[700],
                              size: 22,
                            ),
                            title: Text(
                              'Tax code',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              user.taxCode.isNotEmpty
                                  ? user.taxCode
                                  : 'Unspecified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            leading: Icon(
                              Icons.calendar_today,
                              color: Colors.grey[700],
                              size: 22,
                            ),
                            title: Text(
                              'Birth date',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              user.birthDate != null
                                  ? '${user.birthDate!.day}/${user.birthDate!.month}/${user.birthDate!.year}'
                                  : 'Unspecified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            leading: Icon(
                              Icons.location_city,
                              color: Colors.grey[700],
                              size: 22,
                            ),
                            title: Text(
                              'Birth place',
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              user.birthPlace.isNotEmpty
                                  ? user.birthPlace
                                  : 'Unspecified',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Row(
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
                                'Modify',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
