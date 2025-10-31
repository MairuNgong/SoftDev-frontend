import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/pages/main_page.dart';

const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C);

class OfferSummaryPage extends StatelessWidget {
  final List<dynamic> myItems; // [{"name": "หนังสือ", "image": "https://..."}]
  final List<dynamic> theirItems; // เช่นเดียวกัน
  final String opponentName;
  final String opponentEmail;
  final VoidCallback onConfirm;

  const OfferSummaryPage({
    super.key,
    required this.myItems,
    required this.theirItems,
    required this.opponentName,
    required this.opponentEmail,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F5),
      appBar: AppBar(
        title: const Text('Summary of exchange offers'),
        backgroundColor: kThemeGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCardHeader(context, "Trade with " + opponentName),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    _buildSectionTitle(context, 'You Gave', Icons.arrow_upward, Colors.redAccent),
                    const SizedBox(height: 8),
                    _buildItemList(myItems, context),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: Icon(Icons.swap_vert_circle_outlined, color: Colors.grey, size: 32),
                      ),
                    ),

                    _buildSectionTitle(context, 'You Received', Icons.arrow_downward, kThemeGreen),
                    const SizedBox(height: 8),
                    _buildItemList(theirItems, context),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text("ยืนยันการเสนอแลก"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kThemeGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    final api = ApiService();
                    final userStorage = UserStorageService();

                    // ดึงข้อมูลผู้ใช้ปัจจุบัน
                    final userString = await userStorage.readUserData();
                    if (userString == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่")),
                      );
                      return;
                    }

                    final userData = jsonDecode(userString);
                    final userEmail = userData["email"];

                    // สร้าง payload
                    final myItemIds = myItems.map((e) {
                      final map = (e is Map<String, dynamic>) ? e : jsonDecode(e);
                      return int.tryParse(map["id"]?.toString() ?? "0") ?? 0;
                    }).where((id) => id > 0).toList();

                    final theirItemIds = theirItems.map((e) {
                      final map = (e is Map<String, dynamic>) ? e : jsonDecode(e);
                      return int.tryParse(map["id"]?.toString() ?? "0") ?? 0;
                    }).where((id) => id > 0).toList();

                    final payload = {
                      "accepterEmail": opponentEmail, // opponentName ตอนนี้ควรเป็นอีเมลแล้ว
                      "offerItems": myItemIds.map((id) => id).toList(),
                      "requestItems": theirItemIds.map((id) => id).toList(),
                    };

                    try {
                      // 🔄 เรียก API
                      print("🧾 DEBUG myItems: $myItems");
                      print("🧾 DEBUG theirItems: $theirItems");
                      print("🧾 DEBUG payload: ${jsonEncode(payload)}");
                      await api.createOffer(payload);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🎉 ส่งข้อเสนอเรียบร้อยแล้ว!")),
                      );

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => MainPage(
                          onLogout: () async {}, // ✅ เพิ่ม callback ว่างๆ ไว้ก่อน
                        ),
                      ),
                      (route) => false,
                    );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("❌ ส่งข้อเสนอไม่สำเร็จ: $e")),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, String name) {
    return Row(
      children: [
        const Icon(
          Icons.sync_alt,
          color: kThemeGreen,
          size: 28,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Trade with $name",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  /// 🧩 แสดงชื่อ + รูปของแต่ละ item
  Widget _buildItemList(List<dynamic> items, BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("ไม่มีไอเท็มในรายการนี้", style: TextStyle(color: Colors.grey)),
      );
    }

    return Column(
      children: items.map((itemStr) {
        // แปลง string → Map
        final Map<String, dynamic> item = (itemStr is Map<String, dynamic>) ? itemStr : jsonDecode(itemStr);

        final String name = item["name"] ?? "ไม่ทราบชื่อ";
        final String? imageUrl = item["image"];

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      )
                    : const Icon(Icons.image_outlined, color: Colors.grey, size: 50),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
