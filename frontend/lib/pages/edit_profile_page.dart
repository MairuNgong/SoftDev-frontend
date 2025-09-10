import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController(text: "dogetim");
  final _location = TextEditingController(text: "Bangkok, Thailand");

  String? _localImagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) {
      setState(() => _localImagePath = x.path);
    }
  }

  ImageProvider _avatarProvider() {
    if (_localImagePath != null) {
      return FileImage(File(_localImagePath!));
    }
    return const NetworkImage(
      "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300",
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // ตอนนี้แค่ print ผลลัพธ์ (ภายหลังค่อยยิง backend ได้)
      debugPrint("Username: ${_username.text}");
      debugPrint("Location: ${_location.text}");
      debugPrint("Avatar: $_localImagePath");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated (mock)!")),
      );
      Navigator.pop(context); // กลับไปหน้าก่อน
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        children: [
          // Avatar + ปุ่มแก้ไข
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 48, backgroundImage: _avatarProvider()),
                InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.edit, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ฟอร์ม
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "กรอก Username" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _location,
                  decoration: const InputDecoration(
                    labelText: "Location",
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? "กรอก Location" : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text("บันทึก"),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text("ยกเลิก"),
          ),
        ],
      ),
    );
  }
}
