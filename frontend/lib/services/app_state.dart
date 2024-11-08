import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  String _username = '';

  String get username => _username;

  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }
}
