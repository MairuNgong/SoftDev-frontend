// file: pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/home/swipe_card.dart';
import '../models/login/storage_service.dart'; // <-- ปรับ path ให้ถูกต้อง
import '../models/user_model.dart'; // <-- ปรับ path ให้ถูกต้อง

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserStorageService _storageService = UserStorageService();
  User? _user;
  bool _isLoading = true;
  String _currentOption = 'FOR_YOU';
  // Data from backend
  List<String> forYouItems = [];
  List<String> requestItems = [];

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันเพื่อโหลดข้อมูล User ทันทีที่หน้านี้ถูกสร้าง
    _loadUserData();
    _fetchForYou();
    _fetchRequest();
  }

  Future<void> _loadUserData() async {
    try {
      // 1. ดึงข้อมูล userString จาก Secure Storage
      // (อย่าลืมแก้ readUserData ให้ไม่ต้องรับ context ตามคำแนะนำก่อนหน้านี้)
      final userString = await _storageService
          .readUserData(); // หากยังไม่ได้แก้ ก็ส่ง context ไปก่อน

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load user data: $e')));
      }
    } finally {
      // ไม่ว่าจะสำเร็จหรือล้มเหลว ให้หยุดการโหลด
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchForYou() async {
    final api = ApiService();
    try {
      final items = await api.getForYouItems();
      setState(() {
        forYouItems = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching For You items: $e')));
      }
    }
  }
  Future<void> _fetchRequest() async {
    final api = ApiService();
    try {
      final items = await api.getRequestItems();
      setState(() {
        forYouItems = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error fetching For You items: $e')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // ขณะกำลังโหลดข้อมูล
            : _user != null
            ? Column(
                // เมื่อโหลดข้อมูลสำเร็จ
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OptionPage(
                        title: "REQUEST",
                        onPressed: () {
                          setState(() {
                            _currentOption = 'REQUEST';
                          });
                        },
                        textColor: _currentOption == 'REQUEST'
                            ? Color.fromARGB(255, 184, 124, 76)
                            : Color.fromARGB(255, 235, 217, 209),
                      ),
                      Container(
                        height: 20,
                        width: 1.5,
                        color: Color.fromARGB(255, 184, 124, 76),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      OptionPage(
                        title: "FOR YOU",
                        onPressed: () {
                          setState(() {
                            _currentOption = 'FOR_YOU';
                          });
                        },
                        textColor: _currentOption == 'FOR_YOU'
                            ? Color.fromARGB(255, 184, 124, 76)
                            : Color.fromARGB(255, 235, 217, 209),
                      ),
                    ],
                  ),
                  (_currentOption == 'FOR_YOU')
                      ? SwipeCard(items: forYouItems) // For You
                      : SwipeCard(items: requestItems), // Request
                  const SizedBox(height: 20),
                  // const SizedBox(height: 20),
                  // Text("Name: ${_user!.name}"),
                  // const SizedBox(height: 8),
                  // Text("Email: ${_user!.email}"),
                ],
              )
            : const Text("User data not found."), // หากไม่พบข้อมูล
      ),
    );
  }
}

class OptionPage extends StatelessWidget {
  const OptionPage({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor = const Color.fromARGB(255, 184, 124, 76),
  });
  final String title;
  final VoidCallback onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title, style: TextStyle(color: textColor, fontSize: 15)),
    );
  }
}
