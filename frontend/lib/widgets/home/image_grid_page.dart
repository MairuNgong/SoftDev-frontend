// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ImageGridPage extends StatelessWidget {
  final String title;
  final List<dynamic> items;

  const ImageGridPage({
    super.key,
    required this.title,
    required this.items,
  });

  void _showItemDetailDialog(BuildContext context, Map<String, dynamic> item) {
    final List<dynamic> images = item['ItemPictures'] ?? [];
    final String name = item['name'] ?? 'No Name';
    final String priceRange = item['priceRange'] ?? 'N/A';
    final String description = item['description'] ?? 'No description';
    final List<dynamic> categories = item['itemCategories'] ?? [];
    final String ownerEmail = item['ownerEmail'] ?? 'N/A';
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                        name,
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
                if (images.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            images[index],
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
                // Price Range
                _buildDetailRow(Icons.attach_money, 'Price Range', priceRange),
                const SizedBox(height: 12),
                
                // Description
                _buildDetailRow(Icons.description_outlined, 'Description', description),
                const SizedBox(height: 12),

                // Categories (ส่วนที่เพิ่ม)
                if (categories.isNotEmpty) ...[
                  const Row(
                    children: [
                      const Icon(Icons.category_outlined, size: 20, color: Color(0xFF6D8469)),
                      const SizedBox(width: 8),
                      const Text(
                        'Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3D423C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
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
                            child: Text(ownerEmail, style: const TextStyle(fontSize: 14)),
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
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    const Color kThemeGreen = Color(0xFF6D8469);
    const Color kPrimaryTextColor = Color(0xFF3D423C);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kThemeGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color appBarContentColor = Color.fromARGB(255, 247, 244, 234);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        title: Text(
          title,
          style: const TextStyle(
            color: appBarContentColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 116, 136, 115),
        iconTheme: const IconThemeData(
          color: appBarContentColor,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final imageUrl = (item['ItemPictures'] as List<dynamic>?)?.firstOrNull;
            return GestureDetector(
              onTap: () => _showItemDetailDialog(context, item),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, o, s) => const Icon(Icons.broken_image),
                      )
                    : const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
              ),
            );
          },
        ),
      ),
    );
  }
}
