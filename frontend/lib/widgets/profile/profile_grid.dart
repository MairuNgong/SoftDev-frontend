import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/widgets/profile/profile_grid_item.dart';

class ProfileGrid extends StatelessWidget {
  final List<Item> items; // เปลี่ยนจาก List<String> เป็น List<Item>
  final bool isAvailableTab;
  final VoidCallback? onItemChanged; // เพิ่ม callback
  
  const ProfileGrid({
    super.key, 
    required this.items,
    this.isAvailableTab = false,
    this.onItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text("No items to display."),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ProfileGridItem(
          item: item,
          isAvailableTab: isAvailableTab,
          onItemChanged: onItemChanged,
        );
      },
    );
  }
}