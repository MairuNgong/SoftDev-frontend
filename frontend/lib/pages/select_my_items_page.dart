import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/widgets/profile/profile_header.dart';
import 'package:frontend/widgets/profile/profile_header_selectable.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'Offer_summary_page.dart';

const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C);

class SelectMyItemsPage extends StatefulWidget {
  final String targetItemId;
  final String targetItemName;
  final String ownerName;
  final String targetImageUrl;
  final List<Map<String, dynamic>> targetItems;
  final String ownerEmail;
  
  const SelectMyItemsPage({
    super.key,
    required this.targetItemId,
    required this.targetItemName,
    required this.ownerName,
    required this.targetImageUrl,
    required this.targetItems,
    required this.ownerEmail
    });

  @override
  State<SelectMyItemsPage> createState() => _SelectMyItemsPageState();
}

class _SelectMyItemsPageState extends State<SelectMyItemsPage> {
  late Future<ProfileResponse> _myProfile;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    _loadMyProfile();
  }

  Future<void> _loadMyProfile() async {
    final userString = await UserStorageService().readUserData();
    if (userString == null) return;

    final Map<String, dynamic> userData = jsonDecode(userString);
    final String email = userData['email'];

    setState(() {
      _myProfile = ApiService().getUserProfile(email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileResponse>(
      future: _myProfile,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final profileResponse = snapshot.data!;
        final profile = profileResponse.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text("เลือกของของคุณ"),
          ),
          body: Column(
            children: [
              // 🖼 Grid ของไอเท็ม (Selectable)
              Expanded(
                child: ProfileGridSelectable(
                  images: profileResponse.availableItems
                  .map((i) => {
                        'id': i.id,
                        'image': (i.itemPictures != null && i.itemPictures.isNotEmpty
                          ? i.itemPictures.first
                          : 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png'),
                      })
                  .toList(),
                  onSelectionChanged: (selected) {
                    setState(() {
                      _selectedIds
                        ..clear()
                        ..addAll(selected);
                    });
                  },
                ),
              ),

              // ✅ ปุ่มยืนยันด้านล่าง
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OfferSummaryPage(
                                myItems: _selectedIds.map((id) {
                                  final item = profileResponse.availableItems.firstWhere((i) => i.id.toString() == id);
                                  return {
                                    "id": item.id,
                                    "name": item.name ?? "ไม่ทราบชื่อ",
                                    "image": item.itemPictures.isNotEmpty ? item.itemPictures.first : null,
                                  };
                                }).toList(),
                                theirItems: widget.targetItems,
                                opponentName: widget.ownerName,
                                opponentEmail: widget.ownerEmail,
                                onConfirm: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          );
                        },
                                      icon: const Icon(Icons.check , color: Colors.white),
                    label: Text(
                      _selectedIds.isEmpty
                          ? "เลือกอย่างน้อย 1 ชิ้น"
                          : "ยืนยัน (${_selectedIds.length}) ชิ้น",
                          style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedIds.isEmpty
                          ? Colors.grey
                          : kThemeGreen,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTargetItemImage(ProfileResponse profileResponse) {
  try {
    // หา item จาก id เป้าหมาย
    final targetItem = profileResponse.availableItems
        .firstWhere((i) => i.id.toString() == widget.targetItemId);

    if (targetItem.itemPictures.isNotEmpty) {
      return targetItem.itemPictures.first; // คืน URL ของรูปจริง
    }
  } catch (e) {
    debugPrint("⚠️ ไม่พบรูปของ target item: $e");
  }

  // ถ้าไม่มีรูปเลย ให้ใช้ placeholder
  return 'https://upload.wikimedia.org/wikipedia/commons/7/7c/Profile_avatar_placeholder_large.png';
}

}




