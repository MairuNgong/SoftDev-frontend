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
        // --- Section 1: Avatar, Username, Edit Button ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28, // ปรับขนาดให้เล็กลงเล็กน้อย
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  username,
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 36,
                child: FilledButton(
                  onPressed: onEdit,
                      style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF748873), // สีพื้นหลังสีเขียว
                    foregroundColor: Colors.white,            // สีตัวอักษรสีขาว
                    shape: const StadiumBorder(),             // ทำให้ปุ่มเป็นทรงแคปซูล
                  ),
                  child: const Text('Edit'),
                ),
              ),
            ],
          ),
        ),

        // --- Section 2: Stats ---
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatColumn('Items', '12'),
              buildStatColumn('Rating', '4.5'),
              buildStatColumn('Swaps', '34'),
            ],
          ),
        ),

        // --- Section 3: Bio ---
        if (bio != null && bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(bio!, style: text.bodyLarge),
          ),

        // --- Section 4: Location & Contact ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (location.isNotEmpty) ...[
                Icon(Icons.location_on_outlined, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(location, style: text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(width: 16),
              ],
              if (contact != null && contact!.isNotEmpty)
                InkWell(
                  onTap: () { /* TODO: Launch URL */ },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      Icon(Icons.link, size: 16, color: cs.primary),
                      const SizedBox(width: 4),
                      Text(
                        contact!,
                        style: text.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        
        const Divider(indent: 16, endIndent: 16, height: 24),

        // --- Section 5: Interests ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Edit Interests',
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