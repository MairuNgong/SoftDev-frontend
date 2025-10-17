// file: lib/widgets/home/swipe_card_preview.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';

class SwipeCardPreview extends StatefulWidget {
  final Map<String, dynamic> item;
  const SwipeCardPreview({super.key, required this.item});

  @override
  State<SwipeCardPreview> createState() => _SwipeCardPreviewState();
}

class _SwipeCardPreviewState extends State<SwipeCardPreview> {
  late List<SwipeItem> _swipeItems;
  late MatchEngine _matchEngine;

  @override
  void initState() {
    super.initState();

    final itemJson = jsonEncode(widget.item);

    _swipeItems = [
      SwipeItem(
        content: itemJson,
        likeAction: () {
          // ✅ ปัดขวา = เลือก item
          Navigator.of(context, rootNavigator: false).maybePop({
            'selected': true,
            'itemId': widget.item['id'],
          });
        },
        nopeAction: () {
          // ❌ ปัดซ้าย = ไม่เลือก
          Navigator.of(context, rootNavigator: false).maybePop({
            'selected': false,
            'itemId': widget.item['id'],
          });
        },
      ),
    ];

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  @override
  Widget build(BuildContext context) {
    final itemData = widget.item;
    final images = itemData['ItemPictures'] as List?;
    final imageUrl =
        (images != null && images.isNotEmpty) ? images.first : null;

    return SwipeCards(
      matchEngine: _matchEngine,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 🔹 รูปภาพ
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 80),
                )
              else
                Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 80),
                ),

              // 🔹 Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black54,
                      Colors.black87,
                    ],
                  ),
                ),
              ),

              // 🔹 ข้อความด้านล่าง
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      itemData['name'] ?? 'No Name',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itemData['description'] ?? 'No description',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Owner: ${itemData['ownerEmail'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      onStackFinished: () {
        // ✅ ถ้าปัดหมดการ์ด → เท่ากับ "ไม่เลือก"
        Navigator.of(context, rootNavigator: false).maybePop({
          'selected': false,
          'itemId': widget.item['id'],
        });
      },
      itemChanged: (item, index) {},
      upSwipeAllowed: false,
      fillSpace: true,
    );
  }
}
