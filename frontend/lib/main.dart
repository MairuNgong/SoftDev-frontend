import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/models/login/auth_service.dart';
import 'package:frontend/models/login/storage_service.dart'; // <-- 1. Import Service
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/main_page.dart';

void main() async {
  // ✨ แนะนำให้ใส่บรรทัดนี้ เพื่อให้แน่ใจว่า Flutter พร้อมทำงานก่อนเรียกใช้ async
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthService authService;
  bool _isLoggedIn = false;
  // เพิ่ม State สำหรับสถานะการโหลด
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    authService = AuthService();
    // ✨ 3. เรียกฟังก์ชันเพื่อตรวจสอบสถานะการล็อกอินเมื่อแอปเริ่มทำงาน
    _checkLoginStatus();
  }

  /// ตรวจสอบ Token ที่เก็บไว้ในเครื่องเพื่อกำหนดสถานะการล็อกอิน
  Future<void> _checkLoginStatus() async {
    final token = await UserStorageService().readUserToken();
    setState(() {
      _isLoggedIn = token != null; // ถ้ามี token ให้ถือว่าล็อกอินอยู่
      _isLoading = false;          // ตรวจสอบเสร็จสิ้น
    });
  }

  /// Callback สำหรับเปลี่ยนสถานะเป็นล็อกอิน
  void _handleLogin() {
    setState(() {
      _isLoggedIn = true;
      authService = AuthService(); // <-- Re-initialize for new login
    });
  }

  /// Callback สำหรับเปลี่ยนสถานะเป็นล็อกเอาท์
  void _handleLogout() async {
    print('[DEBUG] Logout started');
    try {
      print('[DEBUG] Signing out from Google...');
      await authService.signOutFromGoogle();
      print('[DEBUG] Google sign out complete');
    } catch (e) {
      print("[DEBUG] Google sign out failed: $e");
    }
    print('[DEBUG] Deleting all user storage...');
    await UserStorageService().deleteAll();
    print('[DEBUG] Storage deleted');
    authService.dispose();
    print('[DEBUG] AuthService disposed');
    setState(() {
      _isLoggedIn = false;
      print('[DEBUG] _isLoggedIn set to false');
      authService = AuthService(); // <-- Re-initialize after logout
      print('[DEBUG] AuthService re-initialized');
    });
    print('[DEBUG] Logout finished');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true
      ),
      
      // ✨ 5. ใช้ State ในการเลือกหน้าจอที่จะแสดงผล
      home: _isLoading
          // ถ้ากำลังโหลด: แสดงหน้าจอรอ
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          // ถ้าโหลดเสร็จแล้ว: ตรวจสอบสถานะการล็อกอิน
          : _isLoggedIn
              ? MainPage(onLogout: _handleLogout)
              : LoginPage(onLogin: _handleLogin),
    );
  }
}