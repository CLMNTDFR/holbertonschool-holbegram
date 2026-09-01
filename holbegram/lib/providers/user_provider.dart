import 'package:flutter/material.dart';
import '../methods/auth_methods.dart';
import '../models/user.dart';

// holds the logged-in Users object so screens can read it.
class UserProvider with ChangeNotifier {
  Users? _user;
  final AuthMethode _authMethode = AuthMethode();

  Users? get user => _user;

  Future<void> refreshUser() async {
    Users user = await _authMethode.getUserDetails();
    _user = user;
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
