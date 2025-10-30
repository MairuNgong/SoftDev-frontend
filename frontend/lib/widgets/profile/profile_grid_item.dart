import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/pages/item_detail_grid_page.dart';

class ProfileGridItem extends StatelessWidget {
  final Item item;
  final bool isAvailableTab;
  final VoidCallback? onItemChanged; // เพิ่ม callback เมื่อมีการเปลี่ยนแปลง item
  
  const ProfileGridItem({
    super.key, 
    required this.item,
    this.isAvailableTab = false,
    this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.itemPictures.isNotEmpty 
        ? item.itemPictures.first 
        : 'https://via.placeholder.com/300';

    return InkWell(
      onTap: () async {
        // ตรวจสอบ ID ก่อนไปหน้า detail
        if (item.id <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot view item details: Invalid item data'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        // ไปหน้า detail โดยส่ง isOwner ตามว่าเป็นแท็บ Available หรือไม่
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailGridPage(
              item: item,
              isOwner: isAvailableTab, // Available tab = เป็นเจ้าของ, แท็บอื่น = ไม่ใช่เจ้าของ
            ),
          ),
        );
        
        // ถ้ามีการเปลี่ยนแปลง (เช่น ลบ item) ให้เรียก callback
        if (result == true && onItemChanged != null) {
          onItemChanged!();
        }
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(color: Colors.grey.shade200);
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          );
        },
      ),
    );
  }
}