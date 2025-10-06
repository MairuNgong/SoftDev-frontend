import 'package:flutter/material.dart';
import 'package:frontend/models/category_model.dart';
import 'package:frontend/widgets/category_card.dart';

// List ข้อมูลกลาง (เหมือนเดิม)
final List<Category> allCategories = [
  Category(id: '1', name: 'Art', icon: Icons.palette_outlined),
  Category(id: '2', name: 'Books', icon: Icons.book_outlined),
  Category(id: '3', name: 'Cooking', icon: Icons.kitchen_outlined),
  Category(id: '4', name: 'Toys', icon: Icons.toys_outlined),

  Category(id: '5', name: 'Gaming', icon: Icons.sports_esports_outlined),
  Category(id: '6', name: 'Gym', icon: Icons.fitness_center_outlined),
  Category(id: '7', name: 'Music', icon: Icons.headphones_outlined),
  Category(id: '8', name: 'Photography', icon: Icons.camera_alt_outlined),
  Category(id: '9', name: 'Traveling', icon: Icons.flight_takeoff_outlined),
Category(id: '10', name: 'Clothing', icon: Icons.checkroom),
Category(id: '11', name: 'Electronics', icon: Icons.devices_other),
Category(id: '12', name: 'Sports', icon: Icons.sports_soccer),
Category(id: '13', name: 'Entertainment', icon: Icons.movie),
Category(id: '14', name: 'Furniture', icon: Icons.chair_alt),



  // Category

  // Category(id: '10', name: 'Yoga', icon: Icons.self_improvement_outlined),
];

// ✨ เพิ่มหน้าเต็มจอสำหรับเลือก Category
class CategorySelectionPage extends StatefulWidget {
  final Set<String> initialSelectedIds;
  const CategorySelectionPage({super.key, this.initialSelectedIds = const {}});

  @override
  State<CategorySelectionPage> createState() => _CategorySelectionPageState();
}

class _CategorySelectionPageState extends State<CategorySelectionPage> {
  late final Set<String> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = Set.from(widget.initialSelectedIds);
  }

  void _onCategoryTap(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _onSave() {
    Navigator.pop(context, _selectedCategoryIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Interests"),
        backgroundColor: const Color(0xFF748873),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                return CategoryCard(
                  category: category,
                  isSelected: _selectedCategoryIds.contains(category.id),
                  onTap: () => _onCategoryTap(category.id),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onSave,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF748873),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategorySelectionModal extends StatefulWidget {
  final Set<String> initialSelectedIds;
  const CategorySelectionModal({super.key, this.initialSelectedIds = const {}});

  @override
  State<CategorySelectionModal> createState() => _CategorySelectionModalState();
}

class _CategorySelectionModalState extends State<CategorySelectionModal> {
  late final Set<String> _selectedCategoryIds;

  @override
  void initState() {
    super.initState();
    _selectedCategoryIds = Set.from(widget.initialSelectedIds);
  }

  void _onCategoryTap(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _onSave() {
    Navigator.pop(context, _selectedCategoryIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) {
        //  ครอบ Column ด้วย Container เพื่อสร้างพื้นหลังสีขาวขอบมน
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Your Interests', style: Theme.of(context).textTheme.titleLarge),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    return CategoryCard(
                      category: category,
                      isSelected: _selectedCategoryIds.contains(category.id),
                      onTap: () => _onCategoryTap(category.id),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onSave,
                    // ✨ 2. เพิ่ม Style สีเขียวให้ปุ่ม
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF748873),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Save'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}