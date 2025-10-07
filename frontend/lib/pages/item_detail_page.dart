import 'dart:convert';
import 'package:flutter/material.dart';
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
    // 🔹 SwipeCard ต้องการ list ของ String
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

          // ✅ ปัดซ้ายหมด stack → กลับไป Search
          onStackFinishedCallback: () {
            Navigator.pop(context);
          },

          // ✅ ไม่ต้องโหลดเพิ่ม เพราะมีแค่ใบเดียว
          onItemChangedCallback: (_) {},

          // ✅ ปัดขวา (Like) — จะทำอะไรเพิ่มก็ได้
          onLikeAction: (itemJson) {
            print("Liked item: $itemJson");
          },
        ),
      ),
    );
  }
}
