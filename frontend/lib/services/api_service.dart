// file: services/api_service.dart

import 'package:dio/dio.dart';
import 'package:frontend/models/user_profile_model.dart';
import '../models/login/storage_service.dart'; // <-- import storage service

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
}