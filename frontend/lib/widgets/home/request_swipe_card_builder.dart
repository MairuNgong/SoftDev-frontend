// file: widgets/home/request_swipe_card_builder.dart

// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Needed for .firstOrNull
import 'package:frontend/widgets/home/image_grid_page.dart';

Widget buildRequestSwipeCard(BuildContext context, String itemJson) {
  final data = jsonDecode(itemJson);
  final String otherPartyEmail = data['otherPartyEmail'] ?? 'Unknown Trader';
  final String status = data['status'] ?? 'Unknown Status';

  final List<dynamic> itemsToReceiveRaw = data['itemsToReceive'] ?? [];
  final List<dynamic> itemsToGiveRaw = data['itemsToGive'] ?? [];

  // Helper widget to display a horizontal list of images (remains the same)
  Widget _buildImageRow(String title, List<dynamic> itemsData) {
    if (itemsData.isEmpty) {
      return Text(
        '$title No items found.',
        style: const TextStyle(color: Colors.white70),
      );
    }
    final double availableHeight = MediaQuery.of(context).size.height;
    final double targetHeight = availableHeight * 0.275;
    final bool isSingleItem = itemsData.length == 1;

    List<Map<String, dynamic>> mappedItems = itemsData.map((item) {
      final Map<String, dynamic> fullItem = {...item};

      // priceRange and description are explicitly set (with fallbacks)
      fullItem['priceRange'] = fullItem['priceRange'] ?? 'N/A';
      fullItem['description'] = fullItem['description'] ?? 'No description';
      fullItem['itemCategories'] =
          fullItem['ItemCategories'] ?? fullItem['itemCategories'] ?? [];

      // pictures and owner email are present (often already there, but safe to check)
      fullItem['ItemPictures'] = fullItem['ItemPictures'] ?? [];
      fullItem['ownerEmail'] = fullItem['ownerEmail'] ?? 'N/A';

      return fullItem;
    }).toList();

    Widget imageContent;
    if (isSingleItem) {
      final item = mappedItems.first;
      final imageUrl = (item['ItemPictures'] as List<dynamic>?)?.firstOrNull;
      imageContent = GestureDetector(
        onTap: () {
          // Show popup like grid page
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3D423C),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((item['ItemPictures'] as List<dynamic>?)?.isNotEmpty ?? false) ...[
                          SizedBox(
                            height: 200,
                            child: PageView.builder(
                              itemCount: (item['ItemPictures'] as List<dynamic>).length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    (item['ItemPictures'] as List<dynamic>)[index],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.error_outline, size: 40),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 20, color: Color(0xFF6D8469)),
                            const SizedBox(width: 8),
                            const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D423C))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item['priceRange'] ?? 'N/A', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.description_outlined, size: 20, color: Color(0xFF6D8469)),
                            const SizedBox(width: 8),
                            const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D423C))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item['description'] ?? 'No description', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                        const SizedBox(height: 12),
                        if ((item['itemCategories'] as List<dynamic>?)?.isNotEmpty ?? false) ...[
                          Row(
                            children: [
                              const Icon(Icons.category_outlined, size: 20, color: Color(0xFF6D8469)),
                              const SizedBox(width: 8),
                              const Text('Categories', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D423C))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: (item['itemCategories'] as List<dynamic>).map((cat) {
                              return Chip(
                                label: Text(cat.toString()),
                                backgroundColor: const Color(0xFF6D8469).withOpacity(0.1),
                                labelStyle: const TextStyle(fontSize: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                visualDensity: VisualDensity.compact,
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6D8469).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF6D8469).withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 20, color: Color(0xFF6D8469)),
                                  const SizedBox(width: 8),
                                  const Text('Owner Contact', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3D423C))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(item['ownerEmail'] ?? 'N/A', style: const TextStyle(fontSize: 14)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: Container(
          height: targetHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null && imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) => const Icon(Icons.broken_image),
                )
              : const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
        ),
      );
    } else {
      imageContent = SizedBox(
        height: targetHeight,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mappedItems.length,
          itemBuilder: (context, index) {
            final item = mappedItems[index];
            final imageUrl =
                (item['ItemPictures'] as List<dynamic>?)?.firstOrNull;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: targetHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) =>
                            const Icon(Icons.broken_image),
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            );
          },
        ),
      );
    }
    Widget rowContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 184, 124, 76),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                mappedItems.length > 1
                    ? '${mappedItems.length} items'
                    : '1 item',
                style: const TextStyle(
                  color: Color.fromARGB(255, 247, 244, 234),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        imageContent,
      ],
    );
    // If more than one item, make row tappable to show grid
    if (!isSingleItem) {
      rowContent = GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ImageGridPage(title: title, items: mappedItems),
            ),
          );
        },
        child: rowContent,
      );
    }
    return rowContent;
  }

  return SizedBox.expand(
    child: Container(
      // padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 116, 136, 115),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // 1. Image Content (fills the entire card, with padding)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                16,
              ), // Apply padding to the scrollable content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageRow('They Request (You Give):', itemsToGiveRaw),
                  const SizedBox(height: 16),
                  _buildImageRow(
                    'They Offer (You Receive):',
                    itemsToReceiveRaw,
                  ),
                ],
              ),
            ),
          ),

          // 2. 🟢 FADE OVERLAY: positioned at the bottom, covers the content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // 3. 🟢 HEADER TEXT: positioned at the bottom, over the fade
          Positioned(
            bottom: -6,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: Colors.white54, height: 20),
                Text(
                  'Trade Request from',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  otherPartyEmail,
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                Text(
                  'Status: $status',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
