import 'package:flutter/material.dart';
import 'package:frontend/widgets/login/social_login_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/models/login/auth_service.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginPage({super.key, required this.onLogin});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ทำให้ AuthService สามารถเข้าถึงได้ทั้งคลาส
  final AuthService _authService = AuthService();
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<String> _backgroundImages = [
    'assets/login/login_bg_1.jpg',
    'assets/login/login_bg_2.jpg',
    'assets/login/login_bg_3.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // ✨ 1. แก้ไขการเรียกใช้ handleDeepLink
    _authService.handleDeepLink(
      onResult: (success, message) {
        if (success) {
          // ถ้าสำเร็จ ก็เรียก onLogin เพื่อเปลี่ยนหน้า
          widget.onLogin();
        } else if (message != null) {
          // ถ้าล้มเหลว ให้แสดง SnackBar
          // ตรวจสอบ `mounted` เพื่อความปลอดภัย
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.red),
            );
          }
        }
      },
    );

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients && _pageController.page != null) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= _backgroundImages.length) nextPage = 0;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeIn,
        );
      }
    });
  }

  // ✨ 2. สร้างฟังก์ชันสำหรับจัดการการกดปุ่มโดยเฉพาะ
  void _handleGoogleLogin() async {
    try {
      // เรียกใช้ AuthService ที่ไม่มี context
      await _authService.launchGoogleAuthUrl();
    } catch (e) {
      // ดักจับ Exception ที่ Service โยนกลับมา
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _authService.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _backgroundImages.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_backgroundImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
          Opacity(
            opacity: 0.5,
            child: Container(color: const Color.fromARGB(255, 235, 217, 209)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Twinder",
                    style: GoogleFonts.marcellusSc(
                      fontSize: 80,
                      fontWeight: FontWeight.normal,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      shadows: const [
                        Shadow(
                          color: Color.fromARGB(255, 184, 124, 76),
                          blurRadius: 4,
                          offset: Offset(2.0, 4.0),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 400,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            SocialLoginButton(
                              // ✨ 3. เรียกใช้ฟังก์ชันที่สร้างไว้ใน onPressed
                              onPressed: _handleGoogleLogin,
                              icon: Icons.g_mobiledata,
                              label: "Continue with Google",
                              backgroundColor:
                                  const Color.fromARGB(255, 116, 136, 115),
                              textColor:
                                  const Color.fromARGB(255, 247, 244, 234),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}