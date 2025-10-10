import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'dart:async';

class AuthService {
  final _userStorageService = UserStorageService();
  final appLinks = AppLinks();
  StreamSubscription? _sub;

  final String _authUrl = dotenv.env['BACKEND_API_URL']!;

  // 1. แก้ไข launchGoogleAuthUrl
  // เอา BuildContext ออก และใช้ throw Exception แทน
  Future<void> launchGoogleAuthUrl() async {
    // ✨ บังคับให้เลือก account ใหม่ทุกครั้งและเคลียร์ session
    final uri = Uri.parse('$_authUrl/auth/google?prompt=select_account&prompt=consent&access_type=offline');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // เมื่อเกิด Error ให้โยน Exception ออกไป
      throw Exception("Failed to launch URL: $uri");
    }
  }

  // ✨ เพิ่มฟังก์ชันสำหรับ Google Sign Out
  Future<void> signOutFromGoogle() async {
    // เปิด Google logout page เพื่อเคลียร์ session
    final uri = Uri.parse('https://accounts.google.com/logout');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // ไม่ต้อง throw error หาก logout ไม่สำเร็จ
      print("Google logout failed: $e");
    }
  }

  // 2. แก้ไข handleDeepLink
  // เปลี่ยน Callback ให้สามารถรับสถานะและข้อความ Error ได้
  void handleDeepLink({
    required Function(bool success, String? message) onResult,
  }) {
    _sub = appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        final token = uri.queryParameters['token'];
        final userString = uri.queryParameters['user'];

        if (token != null && userString != null) {
          try {
            await _handleTokenAndUser(token, userString);
            // ✨ แจ้งผลลัพธ์ว่าสำเร็จ
            onResult(true, null);
          } catch (e) {
            // ✨ แจ้งผลลัพธ์ว่าล้มเหลว พร้อมข้อความ Error
            onResult(false, e.toString());
          }
        } else {
          // ✨ แจ้งผลลัพธ์ว่าล้มเหลว พร้อมข้อความ Error
          onResult(false, 'Login failed: Missing token or user data.');
        }
      }
    }, onError: (Object err) {
      // ✨ แจ้งผลลัพธ์ว่าล้มเหลว พร้อมข้อความ Error
      onResult(false, 'An error occurred while handling deep link.');
    });
  }

  // 3. แก้ไข _handleTokenAndUser
  // เอา BuildContext ออก และใช้ throw Exception แทน
  Future<void> _handleTokenAndUser(String token, String userString) async {
    try {
      await _userStorageService.saveUserToken(token);
      await _userStorageService.saveUserData(userString);
    } catch (e) {
      // เมื่อเกิด Error ให้โยน Exception ออกไป
      throw Exception('Failed to save user session.');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}