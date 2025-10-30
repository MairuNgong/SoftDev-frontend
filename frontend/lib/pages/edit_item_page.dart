import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/category_selection_modal.dart';

class EditItemPage extends StatefulWidget {
  final Item item;
  
  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  List<String> _selectedCategories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // ตั้งค่าเริ่มต้นจากข้อมูล item ปัจจุบัน
    _nameController.text = widget.item.name;
    _priceRangeController.text = widget.item.priceRange;
    _descriptionController.text = widget.item.description;
    _selectedCategories = List.from(widget.item.itemCategories);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceRangeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openCategoryModal() async {
    // แปลง category names เป็น IDs สำหรับ modal
    final currentSelectedIds = allCategories
        .where((cat) => _selectedCategories.contains(cat.name))
        .map((cat) => cat.id)
        .toSet();

    final List<String>? newSelectedIds = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (context) => CategorySelectionPage(initialSelectedIds: currentSelectedIds),
      ),
    );

    if (newSelectedIds != null) {
      // แปลง IDs กลับเป็น names
      final newCategoryNames = allCategories
          .where((cat) => newSelectedIds.contains(cat.id))
          .map((cat) => cat.name)
          .toList();

      setState(() {
        _selectedCategories = newCategoryNames;
      });
    }
  }

  void _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // สร้างข้อมูลที่จะส่งไป API
      final Map<String, dynamic> itemData = {
        'name': _nameController.text.trim(),
        'priceRange': _priceRangeController.text.trim(),
        'description': _descriptionController.text.trim(),
        'categoryNames': _selectedCategories,
      };
      
      // ตรวจสอบว่า item ID ถูกต้องหรือไม่
      if (widget.item.id <= 0) {
        throw Exception('Cannot edit item: Invalid item ID (${widget.item.id}). This item may have loading issues.');
      }

      // เรียก API update item
      await ApiService().updateItem(
        itemId: widget.item.id,
        itemData: itemData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // กลับไปหน้าก่อนหน้าพร้อมส่งสัญญาณว่ามีการอัปเดต
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update item: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: const Color(0xFF5B7C6E),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ชื่อสินค้า
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter item name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ช่วงราคา
              TextFormField(
                controller: _priceRangeController,
                decoration: const InputDecoration(
                  labelText: 'Price Range *',
                  hintText: 'e.g., 30000-35000',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter price range';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // คำอธิบาย
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // หมวดหมู่
              const Text(
                'Categories *',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCategories.isEmpty)
                      const Text(
                        'No categories selected',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        children: _selectedCategories.map((category) {
                          return Chip(
                            label: Text(category),
                            backgroundColor: const Color(0xFF5B7C6E).withOpacity(0.1),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _openCategoryModal,
                      icon: const Icon(Icons.category),
                      label: const Text('Select Categories'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B7C6E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ข้อมูลเพิ่มเติม
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Images',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    if (widget.item.itemPictures.isEmpty)
                      const Text('No images', style: TextStyle(color: Colors.grey))
                    else
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.item.itemPictures.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.item.itemPictures[index],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.error),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Note: Image editing will be available in future updates',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}