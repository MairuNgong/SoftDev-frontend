import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/pages/additem_page.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/widgets/profile/profile_grid.dart';
import 'package:frontend/widgets/profile/profile_header.dart';
import 'dart:convert';
import 'package:frontend/widgets/category_selection_modal.dart';
import 'package:frontend/widgets/category_selection_modal.dart' show allCategories, CategorySelectionModal;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<ProfileResponse> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfileData();
  }

  Future<ProfileResponse> _fetchProfileData() async {
    final userString = await UserStorageService().readUserData();
    if (userString == null) {
      throw Exception('User data not found in storage');
    }
    final Map<String, dynamic> userDataMap = jsonDecode(userString);
    final String? email = userDataMap['email'];
    if (email == null) {
      throw Exception('Email not found in user data');
    }
    return ApiService().getUserProfile(email);
  }

 //ฟังก์ชันสำหรับเปิด Modal เลือก Category
  void _openCategoryModal(UserProfile userProfile) async {
     final userCategoryNames = userProfile.interestedCategories;

    // ✨ 2. แปลง "ชื่อ" ที่มี ให้กลายเป็น "ID" ที่ถูกต้อง
    final currentSelectedIds = allCategories
        .where((cat) => userCategoryNames.contains(cat.name)) // หา Category ที่ชื่อตรงกัน
        .map((cat) => cat.id)                               // ดึงเฉพาะ ID ออกมา
        .toSet();         


    final List<String>? newSelectedIds = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CategorySelectionModal(initialSelectedIds: currentSelectedIds);
      },
    );

    if (newSelectedIds != null) {
      // เมื่อผู้ใช้กด Save และมีการเปลี่ยนแปลง
      try {
        // แปลง ID กลับเป็น Name เพื่อส่งให้ API
    
        final newCategoryNames = allCategories
            .where((cat) => newSelectedIds.contains(cat.id))
            .map((cat) => cat.name)
            .toList();

        // เรียก ApiService เพื่อส่งข้อมูลไปที่ Backend
        await ApiService().updateUserCategories(newCategoryNames);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interests updated!'), backgroundColor: Colors.green),
        );
        // Refresh หน้าโปรไฟล์ทั้งหมดเพื่อให้เห็นการเปลี่ยนแปลง
        setState(() {
          _profileFuture = _fetchProfileData();
        });

      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileResponse>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('ไม่พบข้อมูลโปรไฟล์'));
        }

        final profileResponse = snapshot.data!;
        final userProfile = profileResponse.user;

        //  เตรียมข้อมูล Category เพื่อส่งให้ Header
        // **สำคัญ:** สมมติว่า UserProfile model ของคุณมี `List<Category> categories`
        final categoryNames = userProfile.interestedCategories.map((c) => c).toList();

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ProfileHeader(
                  username: userProfile.name,
                  location: userProfile.location ?? 'ยังไม่ได้ระบุ',
                  avatarUrl: userProfile.profilePicture ?? 'https://via.placeholder.com/150',
                  bio: userProfile.bio ?? 'ยังไม่ได้ระบุ',
                  contact: userProfile.contact ?? 'ยังไม่ได้ระบุ',

                  // ส่งข้อมูล Category และ Callback ไปให้ ProfileHeader
                  userCategories: categoryNames,
                  onEditCategories: () => _openCategoryModal(userProfile),

                  onEdit: () async {
                    final updatedProfile = await showModalBottomSheet<UserProfile>(
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
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddItemPage()),
              );
            },
            backgroundColor: const Color(0xFF5B7C6E),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}