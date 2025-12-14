import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service để quản lý accounts trên Firebase Firestore
class FirebaseAccountService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'accounts';

  /// Kiểm tra username đã tồn tại chưa
  Future<bool> usernameExists(String username) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(username.toLowerCase())
          .get();
      return doc.exists;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking username: $e');
      }
      return false;
    }
  }

  /// Tạo account mới
  Future<bool> createAccount(String username, String hashedPassword) async {
    try {
      final usernameKey = username.toLowerCase();
      
      // Kiểm tra username đã tồn tại
      if (await usernameExists(usernameKey)) {
        if (kDebugMode) {
          print('Username already exists: $usernameKey');
        }
        return false;
      }

      // Tạo account mới
      await _firestore.collection(_collectionName).doc(usernameKey).set({
        'username': username,
        'passwordHash': hashedPassword,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('Account created successfully: $usernameKey');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating account: $e');
      }
      return false;
    }
  }

  /// Xác thực đăng nhập
  Future<bool> verifyLogin(String username, String hashedPassword) async {
    try {
      final usernameKey = username.toLowerCase();
      final doc = await _firestore
          .collection(_collectionName)
          .doc(usernameKey)
          .get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('Account not found: $usernameKey');
        }
        return false;
      }

      final data = doc.data();
      final storedHash = data?['passwordHash'];

      if (storedHash == hashedPassword) {
        // Cập nhật lastLogin
        await _firestore.collection(_collectionName).doc(usernameKey).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        if (kDebugMode) {
          print('Login successful: $usernameKey');
        }
        return true;
      }

      if (kDebugMode) {
        print('Invalid password for: $usernameKey');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying login: $e');
      }
      return false;
    }
  }

  /// Lấy thông tin account
  Future<Map<String, dynamic>?> getAccount(String username) async {
    try {
      final usernameKey = username.toLowerCase();
      final doc = await _firestore
          .collection(_collectionName)
          .doc(usernameKey)
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting account: $e');
      }
      return null;
    }
  }
}
