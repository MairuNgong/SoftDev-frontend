// file: services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/models/transaction_model.dart';
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
      receiveTimeout: const Duration(seconds: 30),
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
      // ✨ แยก categoryNames ออกมาเพื่อจัดการแยก
      final categoryNames = userData['categoryNames'] as List<String>?;
      final dataWithoutCategories = Map<String, dynamic>.from(userData)..remove('categoryNames');
      
      final formData = FormData.fromMap(dataWithoutCategories);
      
      // ✨ เพิ่ม categoryNames แบบ array ให้ถูกต้อง
      if (categoryNames != null && categoryNames.isNotEmpty) {
        for (var category in categoryNames) {
          formData.fields.add(MapEntry('categoryNames', category));
        }
      }
      
      if (imageFile != null) {
        String fileName = p.basename(imageFile.path);
        formData.files.add(
          MapEntry(
            'ProfilePicture',
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
          ),
        );
      }
      
      print('FormData fields: ${formData.fields}'); // ✨ Debug log
      
      final response = await _dio.put('/users', data: formData);
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      print('DioException updating profile: ${e.response?.data}'); // ✨ Debug log
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      print('Unknown error updating profile: $e'); // ✨ Debug log
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// อัปเดต Category ที่ผู้ใช้สนใจ
  Future<void> updateUserCategories(List<String> categoryNames) async {
    try {
      final body = {'categoryNames': categoryNames};
      print('Updating categories with: $body'); // ✨ Debug log
      final response = await _dio.put('/users', data: body);
      print('Categories update response: ${response.statusCode}'); // ✨ Debug log
    } on DioException catch (e) {
      print('DioException updating categories: ${e.response?.data}'); // ✨ Debug log
      throw Exception(
        'Failed to update categories: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print('Unknown error updating categories: $e'); // ✨ Debug log
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<List<String>> getForYouItems(String email) async {
    try {
      final response = await _dio.get(
        '/items/available_items/',
        queryParameters: {'email': email},
      );
      final List<dynamic> jsonList = response.data['items'];
      List<String> items = jsonList.map((item) => jsonEncode(item)).toList();
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to fetch "For You" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// ดึงข้อมูลประวัติการแลกเปลี่ยนทั้งหมด
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await _dio.get('/transactions');

      // 1. ดึง List ที่อยู่ใน key 'transactions'
      final List<dynamic> transactionListJson = response.data['transactions'];

      // 2. ใช้ .map เพื่อแปลงแต่ละ object ใน list ให้เป็น Transaction object
      final List<Transaction> transactions = transactionListJson
          .map((json) => Transaction.fromJson(json))
          .toList();

      return transactions;
    } on DioException catch (e) {
      throw Exception('Failed to fetch transactions: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

   Future<void> rateTransaction({
    required int transactionId,
    required double score, // ใช้ double เพื่อรองรับคะแนนทศนิยม
  }) async {
    try {
      // Debug logs
      print('rateTransaction called with:');
      print('- transactionId: $transactionId (${transactionId.runtimeType})');
      print('- score: $score (${score.runtimeType})');
      
      // 1. สร้าง body ให้มีโครงสร้างตรงกับที่ Backend ต้องการ
      final body = {
        'transactionId': transactionId,
        'score': score,
      };
      print('Request body: $body');

      // 2. ยิง PUT request ไปที่ /transactions/rate พร้อมกับส่ง body
      // dio จะใส่ Header 'Content-Type: application/json' ให้เอง
      final response = await _dio.post(
        '/transactions/rate',
        data: body,
      );
      print('Response: ${response.statusCode} - ${response.data}');
    } on DioException catch (e) {
      // 3. จัดการ Error ที่อาจเกิดขึ้น
      throw Exception('Failed to submit rating: ${e.response?.data['message'] ?? e.message}');
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
      throw Exception('Failed to fetch "Request" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> createOffer({
    required String targetItemId,
    required String offeredItemId,
    required String userEmail,
  }) async {
    final Map<String, dynamic> requestBody = {
      'targetItemId': targetItemId,
      'offeredItemId': offeredItemId,
      'userEmail': userEmail,
    };

    try {
      final response = await _dio.post(
        '/transactions/offer',
        data: requestBody,
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to create offer. Server responded with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to send offer request: $e');
    }
  }


  Future<void> createItemWithImage({
    required String name,
    required String priceRange,
    required String description,
    required List<String> categoryNames,
    File? ItemPicture,
  }) async {
    try {
      // ✅ Debug log
      print("📤 [CREATE ITEM BODY]");
      print("name: $name");
      print("priceRange: $priceRange");
      print("description: $description");
      print("categoryNames: $categoryNames");
      print("ItemPicture: ${ItemPicture?.path}");

      final formData = FormData.fromMap({
        "name": name,
        "priceRange": priceRange,
        "description": description,
        "categoryNames": categoryNames,
        if (ItemPicture != null)
          "ItemPicture": await MultipartFile.fromFile(
            ItemPicture.path,
            filename: ItemPicture.path.split('/').last,
          ),
      });

      final response = await _dio.post("/items", data: formData);

      print("📥 [RESPONSE STATUS] ${response.statusCode}");
      print("📥 [RESPONSE DATA] ${response.data}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Create item failed: ${response.statusCode}");
      }

      print("✅ Item created successfully: ${response.data}");
    } on DioException catch (e) {
      print("❌ DioException: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("❌ Unexpected Error: $e");
      rethrow;
    }
  }

  /// สร้าง item ใหม่
  Future<void> createItem({
    required String name,
    required String priceRange,
    required String description,
    required List<String> categoryNames,
    
  }) async {
    try {
      final body = {
        "name": name,
        "priceRange": priceRange,
        "description": description,
        "categoryNames": categoryNames,
      };

      final response = await _dio.post('/items', data: body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception(
          'Failed to create item. Server responded with status: ${response.statusCode}',
        );
      }

      print('✅ Item created successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Failed to create item: ${e.response?.data ?? e.message}');
      throw Exception('Failed to create item: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// ค้นหาสินค้าตาม keyword และหมวดหมู่
  Future<List<dynamic>> searchItems({
    required String keyword,
    required List<String> categories,
  }) async {
    try {
      final body = {
        "keyword": keyword,
        "categories": categories,
      };

      print('📤 [SEARCH REQUEST BODY] $body'); // ✅ ดู body ที่ส่งไปจริง ๆ
      print('🌍 Using base URL: ${_dio.options.baseUrl}');

      final response = await _dio.post('/items/search', data: body);

      print('📋 [HEADERS] ${_dio.options.headers}');
      print('📥 [SEARCH RESPONSE STATUS] ${response.statusCode}');
      print('📥 [SEARCH RESPONSE DATA] ${response.data}'); // ✅ ดู response ทั้งก้อน

      if (response.statusCode == 200) {
        // สมมติ backend ส่งกลับมาเป็น list ของ item
        return response.data['items'];
      } else {
        throw Exception(
          'Failed to search items. Status code: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('❌ [DIO ERROR] ${e.response?.data ?? e.message}');
      throw Exception('Search request failed: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('⚠️ [UNEXPECTED ERROR] $e');
      throw Exception('Unexpected error during search: $e');
    }
  }
}
