import 'package:flutter/material.dart';
import 'package:frontend/models/%E0%B8%B5user_profile_model.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/widgets/profile/profile_grid.dart';
import 'package:frontend/widgets/profile/profile_header.dart';

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

  // ฟังก์ชันสำหรับดึงข้อมูลโปรไฟล์
  Future<ProfileResponse> _fetchProfileData() async {
    // ดึง email ของผู้ใช้ที่ login อยู่จาก storage
    final email = await UserStorageService().readUserData().then((userString) {
      // สมมติว่า userString คือ JSON ที่มี key "email"
      // หากโครงสร้างต่างจากนี้ ให้ปรับแก้ส่วนนี้
      if (userString != null) {
        // อาจจะต้อง decode JSON เพื่อเอา email ออกมา
        // แต่ถ้า userString คือ email ตรงๆ ก็ใช้ได้เลย
        // ในเคสของคุณ ต้อง decode ก่อน
        // final userData = jsonDecode(userString);
        // return userData['email'];
        // **สมมติว่าตอนนี้ userString เก็บแค่ email เพื่อความง่าย**
        return "Not FFound"; // <-- **สำคัญ:** เปลี่ยนเป็นวิธีดึง email จริง
      }
      throw Exception('User email not found');
    });

    // เรียกใช้ ApiService เพื่อดึงข้อมูล profile
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
          return Center(
            child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
          );
        }

        // กรณี: ไม่มีข้อมูล
        if (!snapshot.hasData) {
          return const Center(child: Text('ไม่พบข้อมูลโปรไฟล์'));
        }

        // กรณี: โหลดข้อมูลสำเร็จ!
        final profileResponse = snapshot.data!;
        final userProfile = profileResponse.user;

        // สร้าง UI หลักด้วยข้อมูลจริง
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProfileHeader(
                // 5. ส่งข้อมูลจริงจาก API ไปยัง Widget ลูก
                username: userProfile.name,
                location: userProfile.location ?? 'ยังไม่ได้ระบุ', // ใช้ ?? เพื่อกำหนดค่า default ถ้าเป็น null
                avatarUrl: userProfile.profilePicture ?? 'https://via.placeholder.com/150', // ใส่ URL รูปภาพ default
                onEdit: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.95,
                        child: const EditProfilePage(),
                      );
                    },
                  );
                },
              ),
            ),
            // TODO: ในอนาคต `_gridImages` ควรมาจาก profileResponse.items
            ProfileGrid(images: const [
              'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800',
              'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
            ]),
          ],
        );
      },
    );
  }
}