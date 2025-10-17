import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/offer_creation_page.dart';
import 'package:frontend/widgets/home/swipe_card.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  late List<String> _itemAsList;

  @override
  void initState() {
    super.initState();
    _itemAsList = [jsonEncode(widget.item)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      body: SafeArea(
        child: SwipeCard(
          items: _itemAsList,
          key: ValueKey(_itemAsList.length),

          // 👈 ปัดซ้ายกลับไปหน้า SearchPage
          onStackFinishedCallback: () {
            Navigator.pop(context);
          },

          // ✅ ไม่มีการ์ดถัดไป
          onItemChangedCallback: (_) {},

          // 👉 ปัดขวา → ไปหน้า OfferCreationPage
          onLikeAction: (itemJson) {
            final itemData = jsonDecode(itemJson);

            // ✅ เพิ่ม delay เล็กน้อยเพื่อให้ animation ของ swipe จบก่อน
            Future.delayed(const Duration(milliseconds: 50), () {
              if (!context.mounted) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OfferCreationPage(
                    targetItemId: itemData['id'].toString(),
                    targetItemName: itemData['name'] ?? 'Unknown Item',
                    ownerEmail: itemData['ownerEmail'] ?? '',
                    initialSelectedItemId: itemData['id'].toString(),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
