import 'package:flutter/material.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCategory;
  String? _selectedImage;

  final List<String> _categories = [
    "อิเล็กทรอนิกส์",
    "เสื้อผ้า",
    "ของใช้ในบ้าน",
    "กีฬา",
    "อื่น ๆ"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      appBar: AppBar(
        title: const Text("เพิ่มสินค้า"),
        backgroundColor: Color(0xFF5B7C6E),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: เปิด Image Picker
                    setState(() {
                      _selectedImage = "assets/login/login_bg_1.jpg"; // แทนด้วย path ที่เลือก
                    });
                  },
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Color(0xFF5B7C6E),
                    backgroundImage: _selectedImage != null
                        ? AssetImage(_selectedImage!) as ImageProvider
                        : null,
                    child: _selectedImage == null
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "ชื่อสินค้า",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกชื่อสินค้า" : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "ราคา",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? "กรุณากรอกราคา" : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "หมวดหมู่",
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? "กรุณาเลือกหมวดหมู่" : null,
              ),
              const SizedBox(height: 16),

              // Condition
              TextFormField(
                controller: _conditionController,
                decoration: const InputDecoration(
                  labelText: "เงื่อนไข (เช่น มือหนึ่ง/มือสอง)",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "คำอธิบาย",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "โลเคชั่น",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: ส่งข้อมูลไป Backend หรือ API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("บันทึกข้อมูลเรียบร้อย")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Color(0xFF5B7C6E),
                  ),
                  child: const Text(
                    "เพิ่มสินค้า",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
