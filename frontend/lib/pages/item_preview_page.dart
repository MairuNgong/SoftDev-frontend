import 'package:flutter/material.dart';
import 'package:frontend/widgets/home/swipe_card_preview.dart';

class ItemPreviewPage extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemPreviewPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      body: SafeArea(
        child: SwipeCardPreview(item: item),
      ),
    );
  }
}
