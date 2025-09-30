import 'package:flutter/material.dart';

class ProfileGrid extends StatelessWidget {
  final List<String> images;
  const ProfileGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
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

    // ✨ เปลี่ยนจาก SliverGrid เป็น GridView.builder
    return GridView.builder(
      padding: const EdgeInsets.all(1.0),
      // gridDelegate ยังคงใช้ SliverGridDelegateWithFixedCrossAxisCount เหมือนเดิม
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: images.length, // 👈 บอกจำนวนไอเทม
      itemBuilder: (context, index) { // 👈 สร้างไอเทมแต่ละชิ้น
        final url = images[index];

        return InkWell(
          onTap: () {
            // TODO: ไปหน้า detail ของโพสต์
            print('Tapped on image: $url');
          },
          child: Image.network(
            url,
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
      },
    );
  }
}