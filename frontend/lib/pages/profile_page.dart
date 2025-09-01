import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- mock data ---
  static const _username = 'dogetim';
  static const _name = 'timmmmm.csv';
 

  static const _avatarUrl =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300';
  static const _gridImages = [
    'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800',
    'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
    'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
    'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
  ];
  // ------------------

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return CustomScrollView(
      slivers: [
        // Header (avatar + stats)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // username
                Text(_username,
                    style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),

                const SizedBox(height: 12),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundImage: NetworkImage(_avatarUrl),
                    ),
                    const SizedBox(width: 24),
                    _Stat(title: 'Posts', value: '5'),
                    const SizedBox(width: 24),
                    _Stat(title: 'Followers', value: '458'),
                    const SizedBox(width: 24),
                    _Stat(title: 'Following', value: '839'),
                  ],
                ),

                const SizedBox(height: 12),

                // name + bio (หลายบรรทัดได้)
                Text(_name, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),

                const SizedBox(height: 12),

                // action buttons
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        child: const Text('Follow'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Message'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // (ถ้าต้องการ “ไฮไลต์สตอรี่” ใส่ SliverToBoxAdapter แนวนอนเพิ่มตรงนี้ได้)

        // Grid 3 คอลัมน์
        SliverPadding(
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
                final url = _gridImages[index % _gridImages.length];
                return InkWell(
                  onTap: () {
                    // TODO: ไปหน้า detail ของสินค้า/โพสต์
                  },
                  child: Image.network(url, fit: BoxFit.cover),
                );
              },
              childCount: 30, // จำนวนการ์ดที่จะโชว์ (mock)
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;
  const _Stat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(title, style: text.bodySmall),
      ],
    );
  }
}
