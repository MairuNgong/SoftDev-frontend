import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/pages/edit_item_page.dart';

class ItemDetailGridPage extends StatefulWidget {
  final Item item;
  final bool isOwner; // เพิ่ม parameter เพื่อบอกว่าเป็นเจ้าของ item หรือไม่
  
  const ItemDetailGridPage({
    super.key, 
    required this.item,
    this.isOwner = false, // default เป็น false
  });

  @override
  State<ItemDetailGridPage> createState() => _ItemDetailGridPageState();
}

class _ItemDetailGridPageState extends State<ItemDetailGridPage> {
  bool _isDeleting = false;

  void _editItem() async {
    // Navigate to Edit Item Page
    final bool? result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(item: widget.item),
      ),
    );

    // ถ้ามีการแก้ไขสำเร็จ ให้กลับไปหน้าโปรไฟล์และ refresh
    if (result == true) {
      if (mounted) {
        Navigator.pop(context, true); // กลับไปหน้าโปรไฟล์พร้อมบอกให้ refresh
      }
    }
  }

  void _deleteItem() async {
    // แสดง confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${widget.item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isDeleting = true);
      
      try {
        await ApiService().deleteItem(widget.item.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item deleted successfully!"),
              backgroundColor: Colors.green,
            ),
          );
          // กลับไปหน้าโปรไฟล์พร้อมบอกให้ refresh
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete item: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.name),
        backgroundColor: const Color(0xFF5B7C6E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔹 ภาพสินค้า
            SizedBox(
              height: 300,
              child: widget.item.itemPictures.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.item.itemPictures.length,
                      itemBuilder: (context, index) => Image.network(
                        widget.item.itemPictures[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.photo, size: 100, color: Colors.grey),
                    ),
            ),

            // 🔹 รายละเอียดสินค้า
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Price Range: ${widget.item.priceRange}",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item.description.isNotEmpty 
                        ? widget.item.description 
                        : "No description provided.",
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: widget.item.itemCategories.map((category) {
                      return Chip(label: Text(category));
                    }).toList(),
                  ),
                ],
              ),
            ),

            // 🔹 ปุ่มแก้ไขและลบ (แสดงเฉพาะเมื่อเป็นเจ้าของ)
            if (widget.isOwner) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _editItem,
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B7C6E),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isDeleting 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.delete),
                    label: Text(_isDeleting ? "Deleting..." : "Delete"),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
