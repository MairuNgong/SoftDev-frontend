import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/widgets/profile/profile_header.dart';
import 'package:frontend/widgets/profile/profile_header_selectable.dart';
import 'select_my_items_page.dart';

const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C);

class OfferCreationPage extends StatefulWidget {
  final String targetItemId;
  final String targetItemName;
  final String ownerEmail;
  final String? initialSelectedItemId;
  final List<Map<String, dynamic>> selectedTargetItems;

  OfferCreationPage({
    super.key,
    required this.targetItemId,
    required this.targetItemName,
    required this.ownerEmail,
    this.initialSelectedItemId,
    required this.selectedTargetItems
  });

  @override
  State<OfferCreationPage> createState() => _OfferCreationPageState();
}

class _OfferCreationPageState extends State<OfferCreationPage> {
  late Future<ProfileResponse> _ownerProfile;
  final Set<int> _selectedItemIds = {}; // ไอเท็มที่เลือกไว้

  @override
  void initState() {
    super.initState();
    _ownerProfile = ApiService().getUserProfile(widget.ownerEmail);

    // ✅ เลือก item ที่เราปัดไว้ล่วงหน้า
    final preselect = int.tryParse(widget.targetItemId);
    if (preselect != null) {
      _selectedItemIds.add(preselect);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileResponse>(
      future: _ownerProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Error: ${snapshot.error}')));
        }

        final profileResponse = snapshot.data!;
        final profile = profileResponse.user;

        final sortedItems = [...profileResponse.availableItems];
        sortedItems.sort((a, b) {
          if (a.id.toString() == widget.targetItemId) return -1; // a อยู่ก่อน
          if (b.id.toString() == widget.targetItemId) return 1;  // b อยู่หลัง
          return 0;
        });

        // 🔍 หา URL ของรูปที่ตรงกับ item ที่เราปัด
        final preselectedUrls = profileResponse.availableItems
            .where((i) => i.id.toString() == widget.targetItemId)
            .expand((i) => i.itemPictures)
            .toSet();

        return Scaffold(
          appBar: AppBar(title: Text('Profile of ${profile.name}')),
          body: Column(
            children: [
              ProfileHeader(
                username: profile.name,
                location: profile.location ?? 'ไม่ระบุ',
                avatarUrl: profile.profilePicture ??
                    'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png',
                bio: profile.bio ?? '',
                contact: profile.contact ?? '',
                ratingScore: profile.ratingScore,
                availableItemsCount: profileResponse.availableItems.length,
                completeItemsCount: profileResponse.completeItems.length,
                userCategories: profile.interestedCategories,
                onEditCategories: null,
              ),

              // ✅ แสดง item ของเจ้าของ โดยมี tick item ที่เราปัดไว้
              Expanded(
                child: ProfileGridSelectable(
                  images: sortedItems
                      .map((i) => {
                            'id': i.id,
                            'image': (i.itemPictures.isNotEmpty ? i.itemPictures.first : null),
                          })
                      .toList(),
                  initialSelectedUrls: {
                    if (widget.initialSelectedItemId != null) widget.initialSelectedItemId!,
                  },
                  onSelectionChanged: (selected) {
                    setState(() {
                      _selectedItemIds
                        ..clear()
                        ..addAll(selected.map((e) => int.parse(e)));
                    });

                    // print("🟢 DEBUG currently selected IDs: $_selectedItemIds");
                  },
                ),
              ),

              // 🔘 ปุ่มเสนอแลก -> ไปเลือกของของเราเอง
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    label: const Text(
                      "Offer to exchange",
                      style: TextStyle(color: Colors.white), // ✅ ตัวหนังสือสีขาว
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kThemeGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () async {
                    print("📦 DEBUG selected IDs: $_selectedItemIds");
                    print("📋 Available IDs: ${profileResponse.availableItems.map((i) => i.id).toList()}");

                    // ✅ แปลงรายการที่เลือกไว้เป็น list ของ Map และป้องกัน crash
                    final selectedTargetItems = _selectedItemIds.map((id) {
                      final item = profileResponse.availableItems.firstWhere(
                        (i) => i.id == id,
                        orElse: () {
                          // print("⚠️ WARN: item id=$id not found in availableItems");
                          return profileResponse.availableItems.first;
                        },
                      );
                      return {
                        "id": item.id,
                        "name": item.name ?? "ไม่ทราบชื่อ",
                        "image": item.itemPictures.isNotEmpty ? item.itemPictures.first : null,
                      };
                    }).toList();

                    // print("✅ Selected Target Items ↓↓↓");
                    // for (final item in selectedTargetItems) {
                    //   print("- ${item['id']} | ${item['name']} | ${item['image']}");
                    // }

                    // 🟢 ไปหน้าเลือกของของเรา พร้อมส่งหลาย item ไปด้วย
                    final selectedMyItems = await Navigator.push<List<Map<String, dynamic>>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SelectMyItemsPage(
                          targetItems: selectedTargetItems,
                          targetItemId: widget.targetItemId,
                          targetItemName: widget.targetItemName,
                          ownerName: profile.name,
                          targetImageUrl: selectedTargetItems.isNotEmpty
                            ? (selectedTargetItems.first["image"]?.toString() ?? "")
                            : "", // ✅ ป้องกัน Bad state
                          ownerEmail: profile.email ?? "",
                        ),
                      ),
                    );
                  },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
