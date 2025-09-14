import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart'; // <-- import model
import 'package:frontend/services/api_service.dart';     // <-- import service
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  // ✨ 1. รับข้อมูลโปรไฟล์ปัจจุบันเข้ามาทาง Constructor
  final UserProfile currentUserProfile;

  const EditProfilePage({super.key, required this.currentUserProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller จะถูกกำหนดค่าใน initState
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController; // เพิ่ม Bio controller

  File? _selectedImageFile; // เปลี่ยนจาก path มาเป็น File เพื่อให้ใช้งานง่ายขึ้น
  bool _isLoading = false; // ✨ 2. เพิ่ม State สำหรับการโหลด

  @override
  void initState() {
    super.initState();
    // ✨ 3. ใช้ข้อมูลที่รับมาเป็นค่าเริ่มต้นของ Controller
    _nameController = TextEditingController(text: widget.currentUserProfile.name);
    _locationController = TextEditingController(text: widget.currentUserProfile.location);
    _bioController = TextEditingController(text: widget.currentUserProfile.bio);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null) {
      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
    }
  }

  ImageProvider _avatarProvider() {
    // ถ้ามีการเลือกรูปใหม่
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    }
    // ถ้าไม่มีรูปใหม่ แต่มีรูปเก่าจากโปรไฟล์
    if (widget.currentUserProfile.profilePicture != null) {
      return NetworkImage(widget.currentUserProfile.profilePicture!);
    }
    // ไม่มีรูปเลย
    return const AssetImage("assets/placeholder.png"); // แนะนำให้มีรูป placeholder
  }

  // ✨ 4. แก้ไขฟังก์ชัน _save() ให้เรียกใช้ ApiService
  Future<void> _save() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        // รวบรวมข้อมูลจาก Form
        final userData = {
          'name': _nameController.text,
          'Location': _locationController.text,
          'Bio': _bioController.text,
        };

        // เรียกใช้ ApiService
        final updatedProfile = await ApiService().updateUserProfile(
          userData: userData,
          imageFile: _selectedImageFile,
        );

        // แสดงผลลัพธ์และกลับไปหน้าก่อนหน้า
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          // ส่งข้อมูลที่อัปเดตแล้วกลับไปให้ ProfilePage (เผื่ออยาก refresh)
          Navigator.pop(context, updatedProfile);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      // ✨ 5. ปรับปรุง UI ให้รองรับสถานะ loading
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "กรุณากรอกชื่อ" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: "Location"),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(labelText: "Bio"),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _isLoading ? null : _save, // ปิดปุ่มตอนโหลด
                icon: const Icon(Icons.check),
                label: const Text("บันทึก"),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text("ยกเลิก"),
              ),
            ],
          ),
    );
  }
}