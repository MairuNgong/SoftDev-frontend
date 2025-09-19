import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String location;
  final String avatarUrl;
  final String? bio;
  final String? contact;
  final VoidCallback? onEdit;
  final List<String> userCategories;
  final VoidCallback onEditCategories;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.location,
    required this.avatarUrl,
    this.onEdit,
    this.bio,
    this.contact,
    required this.userCategories,
    required this.onEditCategories,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    const greenColor = Color(0xFF748873);
    final editButtonStyle = FilledButton.styleFrom(
      backgroundColor: greenColor, // สีพื้นหลัง
      foregroundColor: Colors.white, // สีตัวอักษรและไอคอน
    );

    // Helper widget (เหมือนเดิม)
    Widget buildStatColumn(String label, String value) {
      // ... โค้ด helper เหมือนเดิม ...
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    // ✨ ครอบด้วย Padding เพื่อเพิ่มระยะห่างจากขอบบนและล่าง
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(avatarUrl),
                ),
                const SizedBox(width: 16),

                // ส่วนของ Username และ Stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username และปุ่ม Edit
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              username,
                              style: text.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: FilledButton(
                              onPressed: onEdit,
                              style: editButtonStyle, // <--- ใช้ style ที่นี่
                              child: const Text('Edit'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 24), // ใช้เส้นคั่นเพื่อแบ่งโซน
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // หัวข้อ
                                Text(
                                  'Interests',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const Spacer(), // ตัวดันไปทางขวา
                                // ปุ่มสำหรับแก้ไข Category
                                IconButton(
                                  onPressed:
                                      onEditCategories, // <--- ปุ่มแก้ Category อยู่ตรงนี้
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                  ),
                                  tooltip: 'Edit Interests',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // ส่วนที่ใช้แสดง Chip ของ Category ที่เลือกไว้
                            if (userCategories.isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: userCategories
                                    .map((name) => Chip(label: Text(name)))
                                    .toList(),
                              )
                            else
                              const Text(
                                'Tap the edit button to add interests!',
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          buildStatColumn('Items', '12'),
                          buildStatColumn('Rating', '4.5'),
                          buildStatColumn('Swaps', '34'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ส่วนของ Bio, Contact
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bio
                if (bio != null && bio!.isNotEmpty) ...[
                  Text(
                    bio!,
                    style: text.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                // Location & Contact
                Row(
                  children: [
                    if (location.isNotEmpty) ...[
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(location, style: text.bodySmall),
                      const SizedBox(width: 12),
                    ],
                    if (contact != null && contact!.isNotEmpty)
                      InkWell(
                        onTap: () {},
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 16, color: cs.primary),
                            const SizedBox(width: 4),
                            Text(
                              contact!,
                              style: text.bodySmall?.copyWith(
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
