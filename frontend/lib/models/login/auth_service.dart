import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'dart:async';

class AuthService {
  final _userStorageService = UserStorageService();
  final appLinks = AppLinks();
  late StreamSubscription _sub;

  final String _authUrl = dotenv.env['BACKEND_API_URL']!;

  Future<void> launchGoogleAuthUrl(BuildContext context) async {
    final uri = Uri.parse('$_authUrl/auth/google');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to launch URL: $uri"), backgroundColor: Colors.red),
      );
    }
  }

  // ✨ เปลี่ยนให้รับ onLoggedIn
  void handleDeepLink(BuildContext context, {required VoidCallback onLoggedIn}) {
    _sub = appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        final token = uri.queryParameters['token'];
        final userString = uri.queryParameters['user'];
        print('userString: $userString');
        print('token: $token');
        print('fsdfsdf');

        if (token != null && userString != null) {
          await _handleTokenAndUser(token, userString, context);
          // ✨ แจ้งไปยัง MyApp ผ่าน LoginPage
          onLoggedIn();
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login failed: Missing token or user data.')),
          );
        }
      }
    }, onError: (Object err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred while handling deep link.')),
        );
      }
    });
  }

  // เก็บ session เท่านั้น ไม่ต้องนำทาง
  Future<void> _handleTokenAndUser(String token, String userString, BuildContext context) async {
    try {
      await _userStorageService.saveUserToken(token);
      await _userStorageService.saveUserData(userString);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save user session.')),
      );
    }
  }

  void dispose() {
    _sub.cancel();
  }
}
