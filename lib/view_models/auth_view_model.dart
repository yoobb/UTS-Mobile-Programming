// lib/view_models/auth_view_model.dart

import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../db/database_helper.dart';

class AuthViewModel extends ChangeNotifier {
  final dbHelper = DatabaseHelper.instance;
  User? _currentUser;

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<bool> login(String username) async {
    final user = await dbHelper.getUserByUsername(username);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String name) async {
    final existingUser = await dbHelper.getUserByUsername(username);
    if (existingUser != null) {
      return false;
    }

    final newUser = User(username: username, name: name);
    final newId = await dbHelper.insertUser(newUser);

    if (newId > 0) {
      _currentUser = User(id: newId, username: username, name: name);
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}