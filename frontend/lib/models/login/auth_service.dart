import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'dart:async';
import 'package:frontend/pages/home_page.dart';

class AuthService {
  final _userStorageService = UserStorageService();
  final appLinks = AppLinks();
  late StreamSubscription _sub;

  final String _authUrl = dotenv.env['BACKEND_API_URL']!;

  // launch the Google auth URL
  Future<void> launchGoogleAuthUrl(BuildContext context) async {
    final String fullUrl = '$_authUrl/auth/google';
    final uri = Uri.parse(fullUrl);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      
      // Debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to launch URL: $fullUrl"),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // handle incoming deep links
  void handleDeepLink(BuildContext context) {
    _sub = appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        final token = uri.queryParameters['token'];
        final userString = uri.queryParameters['user'];
        if (token != null && userString != null) {
          if (!context.mounted) return;
          _handleTokenAndUser(token, userString, context);
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed: Missing token or user data.')),
          );
        }
      }
    }, onError: (Object err) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred while handling deep link.')),
        );
      }
    });
  }

  // saving the user session
  Future<void> _handleTokenAndUser(
      String token, String userString, BuildContext context) async {
    try {
      await _userStorageService.saveUserToken(token);
      await _userStorageService.saveUserData(userString);

      if (!context.mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save user session.')),
      );
    }
  }
  
  // Method to clean up the listener to prevent memory leaks
  void dispose() {
    _sub.cancel();
  }

  // You can add other methods like logout here
}