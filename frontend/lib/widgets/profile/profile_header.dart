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

  // Helper widget สำหรับสร้างคอลัมน์สถิติ
  Widget buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
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

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- ส่วนที่ 1: ข้อมูลหลัก (Avatar, Name, Location) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: cs.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // ปุ่ม Edit Profile หลัก
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Edit Profile',
              ),
            ],
          ),
        ),

        // --- ส่วนที่ 2: สถิติ (Stats) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildStatColumn('Items', '12'),
              buildStatColumn('Rating', '4.5'),
              buildStatColumn('Swaps', '34'),
            ],
          ),
        ),
        
        const Divider(indent: 16, endIndent: 16),

        // --- ส่วนที่ 3: Bio และ Contact ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (bio != null && bio!.isNotEmpty) ...[
                Text(
                  bio!,
                  style: text.bodyMedium,
                ),
                const SizedBox(height: 8),
              ],
              if (contact != null && contact!.isNotEmpty)
                InkWell(
                  onTap: () { /* TODO: Launch URL */ },
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 16, color: cs.primary),
                      const SizedBox(width: 6),
                      Text(
                        contact!,
                        style: text.bodyMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const Divider(indent: 16, endIndent: 16),
        
        // --- ส่วนที่ 4: Interests ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Interests', style: text.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: onEditCategories,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: 'Edit Interests',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (userCategories.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: userCategories.map((name) {
                    return Chip(
                      label: Text(name),
                      labelStyle: text.labelSmall,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                )
              else
                const Text('No interests selected yet.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    ),
  );
}
}