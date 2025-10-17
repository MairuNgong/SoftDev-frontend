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

  const OfferCreationPage({
    super.key,
    required this.targetItemId,
    required this.targetItemName,
    required this.ownerEmail,
    this.initialSelectedItemId,
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
                    // ให้ติ๊ก item ที่มาจากหน้า Home
                    if (widget.initialSelectedItemId != null) widget.initialSelectedItemId!,
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
                      // ✅ หาไอเท็มที่ปัดจาก ownerProfile (มีรูปจริงแน่นอน)
                      final targetItem = profileResponse.availableItems.firstWhere(
                        (i) => i.id.toString() == widget.targetItemId,
                        orElse: () => profileResponse.availableItems.first,
                      );

                      final targetImage = targetItem.itemPictures.isNotEmpty
                          ? targetItem.itemPictures.first
                          : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';

                      // 🟢 ไปหน้าเลือกของของเรา พร้อมส่งรูปเป้าหมายไปด้วย
                      final selectedMyItems = await Navigator.push<List<String>>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectMyItemsPage(
                            targetItemId: widget.targetItemId,
                            targetItemName: widget.targetItemName,
                            ownerName: profile.name,
                            targetImageUrl: targetImage, // ✅ เพิ่มบรรทัดนี้
                          ),
                        ),
                      );

                      if (selectedMyItems != null && selectedMyItems.isNotEmpty) {
                        Navigator.pop(context, {
                          'targetItemId': widget.targetItemId,
                          'targetItemName': widget.targetItemName,
                          'selectedItems': selectedMyItems,
                        });
                      }
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
