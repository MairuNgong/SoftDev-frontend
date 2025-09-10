import 'package:flutter/material.dart';
import 'package:frontend/pages/edit_profile_page.dart';
import 'package:frontend/widgets/profile/profile_grid.dart';
import 'package:frontend/widgets/profile/profile_header.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _username = 'dogetim';
  static const _location = 'Bangkok, Thailand';
  static const _avatarUrl =
      'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300';
  static const _gridImages = [
    'https://images.unsplash.com/photo-1520975916090-3105956dac38?w=800',
    'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
    'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?w=800',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          
          child: ProfileHeader(
            username: _username,
            location: _location,
            avatarUrl: _avatarUrl,
            onEdit: () {
              // TODO: เปิดหน้าแก้ไขโปรไฟล์/BottomSheet
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return const EditProfilePage();
                },
              );
            
            },
          ),
        ),
        ProfileGrid(images: _gridImages),
      ],
    );
  }
}
