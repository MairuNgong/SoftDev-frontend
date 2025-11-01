// file: services/api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:frontend/models/transaction_model.dart';
import 'package:frontend/models/user_profile_model.dart' as profile;
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
  Future<profile.ProfileResponse> getUserProfile(String email) async {
    try {
      final response = await _dio.get('/users/profile/$email');
      return profile.ProfileResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load user profile: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// อัปเดตโปรไฟล์ผู้ใช้ พร้อมอัปโหลดรูปภาพ
  Future<profile.UserProfile> updateUserProfile({
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
      return profile.UserProfile.fromJson(response.data);
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
      final List<dynamic> jsonList = response.data['items'] ?? [];
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
      final response = await _dio.get(
        '/transactions/get_offer',
        queryParameters: {'email': email}
      );
      final List<dynamic> jsonList = response.data['transactions'] ?? [];
      List<Transaction> transactions = jsonList.map((json) => Transaction.fromJson(json)).toList();
      List<String> items = transactions
        .map((t) => jsonEncode(t.toCardJson(email)))
        .toList();
      items.removeWhere((itemJson) => itemJson == '{}');
      return items;
    } on DioException catch (e) {
      throw Exception('Failed to fetch "Request" items: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> postWatchedItems(String email, String itemId) async {
    try {
      final body = {
        "itemId": itemId,
      };
      final response = await _dio.post(
        '/watched',
        queryParameters: {'email': email},
        data: body,
      );
      print('Response: ${response.statusCode} - ${response.data}');
    } on DioException catch (e) {
      throw Exception('Failed to submit watched item: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  Future<void> createOffer(Map<String, dynamic> payload) async {
    try {
      print("🟢 Sending Offer Payload ↓↓↓");
      print(JsonEncoder.withIndent('  ').convert(payload));

      final response = await _dio.post(
        '/transactions/offer',
        data: payload,
      );

      print("📩 Response ${response.statusCode}: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Offer created successfully!");
      } else {
        throw Exception(
          'Failed to create offer. Server responded with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // ✅ เพิ่มส่วนแสดงข้อความจาก backend
      print("❌ DioException while sending offer!");
      print("🧾 Response status: ${e.response?.statusCode}");
      print("🧾 Response data: ${e.response?.data}");
      print("🧾 Request payload: ${jsonEncode(payload)}");
      throw Exception(
        'Failed to send offer request: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      print("❌ Unexpected Error while sending offer: $e");
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

  // ===================== ITEM MANAGEMENT =====================
  
  /// ดึงรายละเอียด Item ตาม ID
  Future<profile.Item> getItemDetail(int itemId) async {
    try {
      final response = await _dio.get('/items/$itemId');
      return profile.Item.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to load item detail: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// ลบ Item ตาม ID
  Future<void> deleteItem(int itemId) async {
    try {
      await _dio.delete('/items/$itemId');
    } on DioException catch (e) {
      throw Exception('Failed to delete item: ${e.message}');
    } catch (e) {
      throw Exception('An unknown error occurred: $e');
    }
  }

  /// อัปเดต Item พร้อมรูปภาพหลายรูป
  Future<profile.Item> updateItem({
    required int itemId,
    required Map<String, dynamic> itemData,
    List<File>? imageFiles,
  }) async {
    try {
      // แยก categoryNames ออกมาเพื่อจัดการแยก
      final categoryNames = itemData['categoryNames'] as List<String>?;
      final dataWithoutCategories = Map<String, dynamic>.from(itemData)..remove('categoryNames');
      
      final formData = FormData.fromMap(dataWithoutCategories);
      
      // เพิ่ม categoryNames แบบ array ให้ถูกต้อง
      if (categoryNames != null && categoryNames.isNotEmpty) {
        for (var category in categoryNames) {
          formData.fields.add(MapEntry('categoryNames', category));
        }
      }
      
      // เพิ่มรูปภาพ (ใช้ ItemPicture แทน ItemPictures)
      if (imageFiles != null && imageFiles.isNotEmpty) {
        String fileName = p.basename(imageFiles.first.path);
        formData.files.add(
          MapEntry(
            'ItemPicture',
            await MultipartFile.fromFile(imageFiles.first.path, filename: fileName),
          ),
        );
      }
      
      print('📤 [UPDATE ITEM] FormData fields: ${formData.fields}');
      print('📤 [UPDATE ITEM] FormData files: ${formData.files.length} files');
      
      final response = await _dio.put('/items/$itemId', data: formData);
      
      print('📥 [UPDATE ITEM RESPONSE] ${response.statusCode}');
      
      return profile.Item.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [UPDATE ITEM ERROR] ${e.response?.data}');
      throw Exception('Failed to update item: ${e.response?.data ?? e.message}');
    } catch (e) {
      print('❌ [UPDATE ITEM UNKNOWN ERROR] $e');
      throw Exception('An unknown error occurred: $e');
    }
  }

  
  Future<void> cancelTransaction(int transactionId) async {
    try {
      print("🟥 Cancelling transaction ID: $transactionId");

      final response = await _dio.put(
        '/transactions/cancel',
        data: {"transactionId": transactionId.toString()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Transaction cancelled successfully");
      } else {
        throw Exception("Failed to cancel transaction: ${response.statusCode}");
      }
    } on DioException catch (e) {
      print("❌ DioException cancelling transaction: ${e.response?.data ?? e.message}");
      throw Exception('Cancel transaction failed: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Unexpected error cancelling transaction: $e');
    }
  }

  Future<void> confirmTransaction(int transactionId) async {
    try {
      final token = await UserStorageService().readUserToken();
      if (token == null) throw Exception("No token found");

      final payload = {"transactionId": transactionId.toString()};
      print("🟢 Sending Confirm Payload: ${jsonEncode(payload)}");

      final response = await _dio.put(
        '/transactions/confirm',
        data: payload,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print("✅ Confirm response: ${response.data}");
    } catch (e) {
      print("❌ Error confirming transaction: $e");
      rethrow;
    }
  }

}
