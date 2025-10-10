import 'dart:io';
import 'package:flutter/material.dart';

import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile currentUserProfile;

  const EditProfilePage({super.key, required this.currentUserProfile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  // ✨ 1. เพิ่ม Controller สำหรับ Contact
  late TextEditingController _contactController;

  File? _selectedImageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUserProfile.name);
    _locationController = TextEditingController(text: widget.currentUserProfile.location);
    _bioController = TextEditingController(text: widget.currentUserProfile.bio);
    // ✨ 2. กำหนดค่าเริ่มต้นให้กับ Contact Controller
    _contactController = TextEditingController(text: widget.currentUserProfile.contact);
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
    if (_selectedImageFile != null) {
      return FileImage(_selectedImageFile!);
    }
    if (widget.currentUserProfile.profilePicture != null) {
      return NetworkImage(widget.currentUserProfile.profilePicture!);
    }
    return const AssetImage("assets/placeholder.png");
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() => _isLoading = true);

      try {
        // ✨ 3. เพิ่ม Contact และ Categories เข้าไปในข้อมูลที่จะส่ง
        final userData = {
          'name': _nameController.text,
          'Location': _locationController.text,
          'Bio': _bioController.text,
          'Contact': _contactController.text,
          // ✨ เพิ่ม categories เดิมไปด้วยเพื่อไม่ให้หาย
          'categoryNames': widget.currentUserProfile.interestedCategories,
        };

        print('Saving profile with categories: ${widget.currentUserProfile.interestedCategories}'); // Debug log

        final updatedProfile = await ApiService().updateUserProfile(
          userData: userData,
          imageFile: _selectedImageFile,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile updated successfully!"),
              backgroundColor: Colors.green,
            ),
          );
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
    
    // ✨ 5. กำหนดสไตล์ปุ่มสีเขียว
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: const Color(0xFF748873), // สีเขียวที่คุณใช้
      foregroundColor: Colors.white,
    );
    
    final outlinedButtonStyle = OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF748873)),
        foregroundColor: const Color(0xFF748873),
    );


    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF748873),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
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
                            color: Color( 0xFF748873),
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
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        validator: (v) => (v == null || v.trim().isEmpty) ? "Please enter your name" : null,
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
                      const SizedBox(height: 16),
                      // ✨ 4. เพิ่ม TextFormField สำหรับ Contact
                      TextFormField(
                        controller: _contactController,
                        decoration: const InputDecoration(
                          labelText: "Contact",
                          hintText: "e.g., Line ID, Facebook, etc."
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: const Icon(Icons.check),
                  label: const Text("Save"),
                  style: buttonStyle, // ✨ 6. ใช้สไตล์ที่กำหนด
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text("Cancel"),
                  style: outlinedButtonStyle, // ✨ 6. ใช้สไตล์ที่กำหนด
                ),
              ],
            ),
    );
  }
}