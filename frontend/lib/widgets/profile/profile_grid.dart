import 'package:flutter/material.dart';

class ProfileGrid extends StatelessWidget {
  final List<String> images;
  const ProfileGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 8),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final url = images[index % images.length];
            return InkWell(
              onTap: () {
                // TODO: ไปหน้า detail ของโพสต์
              },
              child: Image.network(url, fit: BoxFit.cover),
            );
          },
          childCount: 7,
        ),
      ),
    );
  }
}
