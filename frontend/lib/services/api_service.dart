// file: services/api_service.dart

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
          final storage = UserStorageService();
          final token = await storage.readUserToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            print('Token added to header!');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            print('Token expired or invalid.');
          }
          return handler.next(e);
        },
      ),
    );
  }
  // ===================================

  /// ดึงข้อมูลโปรไฟล์ของผู้ใช้จากอีเมล
  Future<ProfileResponse> getUserProfile(String email) async {
    try {
      final response = await _dio.get('/users/profile/$email');
      return ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load user profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// อัปเดตโปรไฟล์ผู้ใช้ พร้อมอัปโหลดรูปภาพ
  Future<UserProfile> updateUserProfile({
    required Map<String, dynamic> userData,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap(userData);
      if (imageFile != null) {
        String fileName = p.basename(imageFile.path);
        formData.files.add(
          MapEntry(
            'ProfilePicture',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }
      final response = await _dio.put(
        '/users',
        data: formData,
      );
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// อัปเดต Category ที่ผู้ใช้สนใจ
  Future<void> updateUserCategories(List<String> categoryNames) async {
    try {
      final body = {'categoryNames': categoryNames};
      await _dio.put(
        '/users',
        data: body,
      );
    } on DioException catch (e) {
      throw Exception('Failed to update categories: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<List<String>> getForYouItems(String email) async {
    try {
      final response = await _dio.get('/un_watched_item/$email');
      List<String> items = List<String>.from(response.data['items']);
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to fetch "For You" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<List<String>> getRequestItems(String email) async {
    try {
      // TODO: ใส่ endpoint ที่ถูกต้อง
      final response = await _dio.get('/...'); 
      List<String> items = List<String>.from(response.data['items']);
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to fetch "Request" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

} 