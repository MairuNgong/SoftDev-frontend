import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String username;
  final String location;
  final String avatarUrl;
  final VoidCallback? onEdit;

  const ProfileHeader({
    super.key,
    required this.username,
    required this.location,
    required this.avatarUrl,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onSurfaceVariant = Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 38,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 16),

          // Username + Location
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แถว: Username + ปุ่ม Edit
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Edit profile',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 20),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Location ใต้ Username
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: onSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(
                          color: onSurfaceVariant,
                        ),
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
