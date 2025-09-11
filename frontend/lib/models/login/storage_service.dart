import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorageService{
  final _storage = const FlutterSecureStorage();

  // save user token
  Future<void> saveUserToken(String token) async {
    await _storage.write(key: 'user_token', value: token);
  }

  // read user token
  Future<String?> readUserToken(context) async {
    try {
      return await _storage.read(key: 'user_token');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading user token: $e')),
      );
      return null;
    }
  }

  // delete user token (logout)
  Future<void> deleteUserToken() async {
    await _storage.delete(key: 'user_token');
  }

  // save user data
  Future<void> saveUserData(String userString) async {
    await _storage.write(key: 'user', value: userString);
  }

  // read user data
  Future<String?> readUserData(context) async {
    try {
      return await _storage.read(key: 'user');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error reading user data: $e')),
      );
      return null;
    }
  }
}