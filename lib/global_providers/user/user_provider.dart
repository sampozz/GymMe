import 'package:dima_project/global_providers/user/user_model.dart';
import 'package:dima_project/global_providers/user/user_service.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  User? _user;

  User? get user => _user;

  Future<User?> getUser() async {
    _user = await _userService.getUser();
    notifyListeners();
    return _user;
  }
}
