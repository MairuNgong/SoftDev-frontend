import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/pages/additem_page.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/widgets/profile/profile_grid.dart';
import 'package:frontend/widgets/profile/profile_header.dart';
import 'dart:convert';

// 1. เปลี่ยนจาก StatelessWidget เป็น StatefulWidget
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 2. สร้างตัวแปร Future เพื่อเก็บผลลัพธ์การดึงข้อมูล Profile
  late Future<ProfileResponse> _profileFuture;

  @override
  void initState() {
    super.initState();
    // 3. เริ่มต้นกระบวนการดึงข้อมูลทันทีที่หน้านี้ถูกสร้าง
    _profileFuture = _fetchProfileData();
  }

  Future<ProfileResponse> _fetchProfileData() async {
    // 1. ดึง userString จาก Storage
    final userString = await UserStorageService().readUserData();

    if (userString == null) {
      // ถ้าไม่มีข้อมูล user ก็โยน Error ไปเลย
      throw Exception('User data not found in storage');
    }

    // 2. แปลง String เป็น Map (เหมือนเปิดจดหมาย)
    final Map<String, dynamic> userDataMap = jsonDecode(userString);

    // 3. ดึงค่า email ออกมาจาก Map ด้วย key 'email'
    final String? email = userDataMap['email'];

    if (email == null) {
      // ถ้าในข้อมูลไม่มี key email ก็โยน Error
      throw Exception('Email not found in user data');
    }

    // 4. เรียกใช้ ApiService ด้วย email ที่ดึงมาได้
    return ApiService().getUserProfile(email);
  }

  @override
  Widget build(BuildContext context) {
    // 4. ใช้ FutureBuilder เพื่อสร้าง UI ตามสถานะของ Future
    return FutureBuilder<ProfileResponse>(
      future: _profileFuture,
      builder: (context, snapshot) {
        // กรณี: กำลังโหลดข้อมูล
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // กรณี: เกิด Error
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        // กรณี: ไม่มีข้อมูล
        if (!snapshot.hasData) {
          return const Center(child: Text('ไม่พบข้อมูลโปรไฟล์'));
        }

        // กรณี: โหลดข้อมูลสำเร็จ!
        final profileResponse = snapshot.data!;
        final userProfile = profileResponse.user;

        // สร้าง UI หลักด้วยข้อมูลจริง
       return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                username: userProfile.name,
                location: userProfile.location ?? 'ยังไม่ได้ระบุ',
                avatarUrl: userProfile.profilePicture ??
                    'https://via.placeholder.com/150',
                onEdit: () async {
                  final updatedProfile =
                      await showModalBottomSheet<UserProfile>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return EditProfilePage(currentUserProfile: userProfile);
                    },
                  );

                  if (updatedProfile != null) {
                    setState(() {
                      _profileFuture = _fetchProfileData();
                    });
                  }
                },
              ),
            ),
            ProfileGrid(
              images: const [
                'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800',
                'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
              ],
            ),
          ],
        ),

        // 👇 ปุ่มกลมๆ ล่างขวา
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddItemPage()),
            );
          },
          backgroundColor: Color(0xFF5B7C6E), // เปลี่ยนสีปุ่มได้
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );

        

      },
    );
  }
}
