// file: pages/home_page.dart

import 'package:flutter/material.dart';
import '../models/login/storage_service.dart'; // <-- ปรับ path ให้ถูกต้อง
import '../models/user_model.dart';           // <-- ปรับ path ให้ถูกต้อง

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserStorageService _storageService = UserStorageService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันเพื่อโหลดข้อมูล User ทันทีที่หน้านี้ถูกสร้าง
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // 1. ดึงข้อมูล userString จาก Secure Storage
      // (อย่าลืมแก้ readUserData ให้ไม่ต้องรับ context ตามคำแนะนำก่อนหน้านี้)
      final userString = await _storageService.readUserData(context); // หากยังไม่ได้แก้ ก็ส่ง context ไปก่อน

      if (userString != null) {
        // 2. แปลง String เป็น User Object ด้วย Model ที่เราสร้างไว้
        final user = User.fromString(userString);
        
        // 3. อัปเดต UI ด้วยข้อมูลใหม่
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      // จัดการ Error หากดึงข้อมูลไม่สำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    } finally {
      // ไม่ว่าจะสำเร็จหรือล้มเหลว ให้หยุดการโหลด
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
     
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // ขณะกำลังโหลดข้อมูล
            : _user != null
                ? Column( // เมื่อโหลดข้อมูลสำเร็จ
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text("Name: ${_user!.name}"),
                      const SizedBox(height: 8),
                      Text("Email: ${_user!.email}"),
                    ],
                  )
                : const Text("User data not found."), // หากไม่พบข้อมูล
      ),
    );
  }
}