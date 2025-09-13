// file: models/login/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserStorageService {
  final _storage = const FlutterSecureStorage();

  // save user token
  Future<void> saveUserToken(String token) async {
    await _storage.write(key: 'user_token', value: token);
  }

  // ✨ แก้ไขตรงนี้: เอา (context) ออก
  Future<String?> readUserToken() async {
    // แค่ return ค่าที่อ่านได้ออกไปเลย
    return await _storage.read(key: 'user_token');
  }

  // delete user token (logout)
  Future<void> deleteUserToken() async {
    await _storage.delete(key: 'user_token');
  }

  // save user data
  Future<void> saveUserData(String userString) async {
    await _storage.write(key: 'user', value: userString);
  }

  // ✨ แก้ไขตรงนี้: เอา (context) ออก
  Future<String?> readUserData() async {
    // แค่ return ค่าที่อ่านได้ออกไปเลย
    return await _storage.read(key: 'user');
  }

  // (Optional) ฟังก์ชันสำหรับลบข้อมูลทั้งหมดตอน Logout
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}