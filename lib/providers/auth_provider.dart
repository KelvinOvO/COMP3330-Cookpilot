// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userName;

  bool get isLoggedIn => _isLoggedIn;
  String? get userName => _userName;

  void login(String userName) {
    _isLoggedIn = true;
    _userName = userName;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userName = null;
    notifyListeners();
  }
}