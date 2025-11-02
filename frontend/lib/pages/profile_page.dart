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
import 'package:frontend/widgets/category_selection_modal.dart' show allCategories, CategorySelectionPage;

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


    final List<String>? newSelectedIds = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionPage(initialSelectedIds: currentSelectedIds),
      ),
    );

    if (newSelectedIds != null) {
      // เมื่อผู้ใช้กด Save และมีการเปลี่ยนแปลง
      try {
        // แปลง ID กลับเป็น Name เพื่อส่งให้ API
    
        final newCategoryNames = allCategories
            .where((cat) => newSelectedIds.contains(cat.id))
            .map((cat) => cat.name)
            .toList();

        print('Selected category IDs: $newSelectedIds'); // ✨ Debug log
        print('Selected category names: $newCategoryNames'); // ✨ Debug log

        // เรียก ApiService เพื่อส่งข้อมูลไปที่ Backend
        await ApiService().updateUserCategories(newCategoryNames);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Interests updated!'), backgroundColor: Colors.green),
        );
        // ✨ รอสักครู่ก่อน refresh เพื่อให้ backend ประมวลผลเสร็จ
        await Future.delayed(const Duration(milliseconds: 500));
        
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

  // ฟังก์ชันสำหรับ refresh profile data
  void _refreshProfile() {
    setState(() {
      _profileFuture = _fetchProfileData();
    });
  }


  @override
Widget build(BuildContext context) {
  return FutureBuilder<ProfileResponse>(
    future: _profileFuture,
    builder: (context, snapshot) {
      // --- ส่วนจัดการสถานะการโหลด (เหมือนเดิม) ---
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.hasError) {
        return Scaffold(body: Center(child: Text('Error occurred: ${snapshot.error}')));
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: Text('Profile data not found')));
      }

      // --- ส่วนเตรียมข้อมูล (เปลี่ยนเป็นส่ง items แทน images) ---
      final profileResponse = snapshot.data!;
      final userProfile = profileResponse.user;
      final categoryNames = userProfile.interestedCategories;

      // --- ✨ โครงสร้าง UI ใหม่ที่เพิ่ม TabBar ---
      return DefaultTabController(
        length: 3, // จำนวนแท็บ
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              // 1. ส่วน Header 
              SliverToBoxAdapter(
                child: ProfileHeader(
                  username: userProfile.name,
                  location: userProfile.location ?? 'Not specified',
                  avatarUrl: userProfile.profilePicture ?? 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png?20150327203541',
                  bio: userProfile.bio ?? 'Not specified',
                  contact: userProfile.contact ?? 'Not specified',
                  userCategories: categoryNames,
                  // ✨ ส่งข้อมูลสถิติจริง
                  availableItemsCount: profileResponse.availableItems.length,
                  ratingScore: userProfile.ratingScore, // ไม่ต้อง .toDouble() แล้วเพราะเป็น double อยู่แล้ว
                  completeItemsCount: profileResponse.completeItems.length,
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
                    // ✨ เฉพาะเมื่อมีการอัปเดตโปรไฟล์จริงๆ ถึงจะ refresh
                    if (updatedProfile != null) {
                      // ✨ รอสักครู่ก่อน refresh เพื่อให้ backend ประมวลผลเสร็จ
                      await Future.delayed(const Duration(milliseconds: 500));
                      setState(() {
                        _profileFuture = _fetchProfileData();
                      });
                    }
                  },
                ),
              ),

              // 2. ส่วน TabBar ที่ปักหมุดได้
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(text: 'Available'),
                      Tab(text: 'Matching'),
                      Tab(text: 'Complete'),
                    ],
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Colors.black,
                  ),
                ),
                pinned: true,
              ),

              // 3. ส่วนเนื้อหาของแต่ละแท็บ
              SliverFillRemaining(
                child: TabBarView(
                  children: [
                    ProfileGrid(
                      items: profileResponse.availableItems, 
                      isAvailableTab: true,
                      onItemChanged: _refreshProfile,
                    ),
                    ProfileGrid(items: profileResponse.matchingItems),
                    ProfileGrid(items: profileResponse.completeItems),
                  ],
                ),
              ),
            ],
          ),
          
          // ส่วนของ FloatingActionButton (เหมือนเดิม)
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // ✨ รอผลลัพธ์จากหน้า AddItemPage
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const AddItemPage()),
              );
              
              // ✨ ถ้า add item สำเร็จ ให้ refresh profile
              if (result == true) {
                setState(() {
                  _profileFuture = _fetchProfileData();
                });
              }
            },
            backgroundColor: const Color(0xFF748873),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      );
    },
  );
}

}



class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}