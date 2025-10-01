// file: services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/models/user_profile_model.dart';
import '../models/login/storage_service.dart'; // <-- import storage service

import 'dart:io'; // <-- import สำหรับใช้ File
import 'package:path/path.dart' as p; // <-- import เพื่อเอาชื่อไฟล์

class ApiService {
  ApiService._internal() {
    // เพิ่ม Interceptor ตอนที่สร้าง object ครั้งแรก
    _addAuthInterceptor();
  }
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://twinder.xyz:7000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  // === ส่วนจัดการ Token อัตโนมัติ ===
  void _addAuthInterceptor() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. สร้าง instance ของ StorageService
          final storage = UserStorageService();
          
          // 2. อ่าน Token ที่เก็บไว้
          final token = await storage.readUserToken(); // แก้เป็น method ที่ไม่มี context

          // 3. ถ้ามี Token, ให้ใส่ใน Header
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Token added to header!');
          }
          
          // 4. ส่ง request ต่อไป
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // (Optional) คุณสามารถจัดการ error ที่เกี่ยวกับ token ได้ตรงนี้
          // เช่น ถ้า token หมดอายุ (ได้ status 401) ก็ให้ redirect ไปหน้า login
          if (e.response?.statusCode == 401) {
            print('Token expired or invalid.');
            // await storage.deleteAll(); // ล้าง token เก่า
            // redirect to login page...
          }
          return handler.next(e);
        },
      ),
    );
  }
  // ===================================

  /// ดึงข้อมูลโปรไฟล์ของผู้ใช้จากอีเมล (แก้ให้ return ProfileResponse)
  Future<ProfileResponse> getUserProfile(String email) async {
    try {
      final response = await _dio.get('/users/profile/$email');
      // ตอนนี้เราไม่ต้องกังวลเรื่องการใส่ Token แล้ว เพราะ Interceptor จัดการให้!
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load user profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// อัปโหลดรูปภาพโปรไฟล์
  Future<UserProfile> updateUserProfile({
    required Map<String, dynamic> userData, // ข้อมูลที่จะอัปเดต
    File? imageFile,                      // รูปภาพ (อาจจะไม่มีก็ได้)
  }) async {
    try {
      // 1. สร้าง FormData object
      // FormData เหมือนกล่องพัสดุที่ใส่ได้ทั้งของ (ไฟล์) และจดหมาย (text)
      final formData = FormData.fromMap(userData);

      // 2. ถ้ามีไฟล์รูปภาพแนบมาด้วย...
      if (imageFile != null) {
        String fileName = p.basename(imageFile.path); // ดึงชื่อไฟล์จาก path
        formData.files.add(
          MapEntry(
            'ProfilePicture', // 'Key' ต้องตรงกับที่ Backend กำหนด
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }
      
      // 3. ยิง PUT request ไปที่ endpoint /users
      // dio จะตั้งค่า Content-Type เป็น multipart/form-data ให้เอง
      final response = await _dio.put(
        '/users',
        data: formData,
      );

      // 4. แปลง JSON ที่ได้รับกลับมาเป็น Object แล้วส่งคืน
      // สังเกตว่า response จาก API ของคุณไม่ได้หุ้มด้วย key 'user'
      return UserProfile.fromJson(response.data); 

    } on DioException catch (e) {
      // จัดการ Error
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<List<String>> getForYouItems(String email) async {
    try {
      final response = await _dio.get('/items/available_items/', queryParameters: {'email': email});
      final List<dynamic> jsonList = response.data['items'];
      List<String> items = jsonList.map((item) => jsonEncode(item)).toList();
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to fetch "For You" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
  Future<List<String>> getRequestItems(String email) async {
    try {
      final response = await _dio.get('/...');
      final List<dynamic> jsonList = response.data['items'];
      List<String> items = jsonList.map((item) => item.toString()).toList();
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to fetch "For You" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }
}