import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/services/api_service.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Image
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Slider สำหรับราคา
  double _minPrice = 0;
  double _maxPrice = 1000;

  // Category พร้อม icon
  final List<Map<String, dynamic>> _categories = [
    {"name": "Art", "icon": Icons.palette_outlined},
    {"name": "Books", "icon": Icons.book_outlined},
    {"name": "Cooking", "icon": Icons.kitchen_outlined},
    {"name": "Toys", "icon": Icons.toys_outlined},
    {"name": "Gaming", "icon": Icons.sports_esports_outlined},
    {"name": "Gym", "icon": Icons.fitness_center_outlined},
    {"name": "Music", "icon": Icons.headphones_outlined},
    {"name": "Photography", "icon": Icons.camera_alt_outlined},
    {"name": "Traveling", "icon": Icons.flight_takeoff_outlined},
    {"name": "Clothing", "icon": Icons.checkroom},
    {"name": "Electronics", "icon": Icons.devices_other},
    {"name": "Sports", "icon": Icons.sports_soccer},
    {"name": "Entertainment", "icon": Icons.movie},
    {"name": "Furniture", "icon": Icons.chair_alt},
  ];
  final List<String> _selectedCategories = [];

  // 🔹 เลือกรูปจาก gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // 🔹 ส่งข้อมูลไป backend
  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final priceRange = "${_minPrice.toInt()}-${_maxPrice.toInt()}";

    try {
      await _apiService.createItemWithImage(
        name: name,
        priceRange: priceRange,
        description: description,
        categoryNames: _selectedCategories,
        ItemPicture: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item added successfully!")),
      );
      // ✨ ส่งสัญญาณกลับว่า add item สำเร็จ
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error occurred: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      appBar: AppBar(
        title: const Text("Add Item"),
        backgroundColor: const Color(0xFF5B7C6E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🔹 Upload Image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: const Color(0xFF5B7C6E),
                  backgroundImage:
                      _selectedImage != null ? FileImage(_selectedImage!) : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Item Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Please enter item name" : null,
              ),
              const SizedBox(height: 16),

              // 🔹 Price Range Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Price Range", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 10000,
                    divisions: 100,
                    labels: RangeLabels(
                      _minPrice.toInt().toString(),
                      _maxPrice.toInt().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                    activeColor: const Color(0xFF5B7C6E),
                  ),
                  Text("฿${_minPrice.toInt()} - ฿${_maxPrice.toInt()}"),
                ],
              ),
              const SizedBox(height: 16),

              // 🔹 Item Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Item Description",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 🔹 Categories with Icon
              Align(
                alignment: Alignment.centerLeft,
                child: const Text("Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategories.contains(cat['name']);
                  return FilterChip(
                    avatar: Icon(cat['icon'], color: selected ? Colors.white : const Color(0xFF5B7C6E)),
                    label: Text(cat['name']),
                    selected: selected,
                    selectedColor: const Color(0xFF5B7C6E),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedCategories.add(cat['name']);
                        } else {
                          _selectedCategories.remove(cat['name']);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submitItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B7C6E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  "Add Item",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
