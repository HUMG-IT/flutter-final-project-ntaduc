import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../services/firebase_account_service.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAccountService _accountService = FirebaseAccountService();
  String? _userName;
  bool _isLoggedIn = false;

  String? get userName => _userName;
  bool get isLoggedIn => _isLoggedIn;
  String get displayName => _userName ?? 'Khách';
  String get userInitial => (_userName?.isNotEmpty ?? false) 
      ? _userName!.substring(0, 1).toUpperCase() 
      : 'K';

  UserProvider();

  // Hash password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign up - create new account
  Future<bool> signUp(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final success = await _accountService.createAccount(username, hashedPassword);
      
      if (kDebugMode) {
        print('Sign up success: $success for user: $username');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      return false;
    }
  }

  // Login with username and password
  Future<bool> login(String username, String password) async {
    try {
      final hashedPassword = _hashPassword(password);
      final success = await _accountService.verifyLogin(username, hashedPassword);
      
      if (success) {
        _userName = username;
        _isLoggedIn = true;
        notifyListeners();
      }
      
      if (kDebugMode) {
        print('Login success: $success for user: $username');
      }
      
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _userName = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
