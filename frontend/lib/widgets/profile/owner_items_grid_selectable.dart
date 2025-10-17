import 'package:flutter/material.dart';
import 'package:frontend/models/user_profile_model.dart'; // ต้องมีคลาส Item

const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C);

class OwnerItemsGridSelectable extends StatefulWidget {
  final List<Item> items;
  final Set<int> initialSelectedIds;
  final ValueChanged<Set<int>>? onSelectionChanged;

  const OwnerItemsGridSelectable({
    super.key,
    required this.items,
    this.initialSelectedIds = const {},
    this.onSelectionChanged,
  });

  @override
  State<OwnerItemsGridSelectable> createState() => _OwnerItemsGridSelectableState();
}

class _OwnerItemsGridSelectableState extends State<OwnerItemsGridSelectable> {
  late Set<int> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<int>.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const Center(child: Text('No items to display.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 3/4,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final isSelected = _selectedIds.contains(item.id);
        final imageUrl = (item.itemPictures.isNotEmpty)
            ? item.itemPictures.first
            : 'https://via.placeholder.com/300x400?text=No+Image';

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(item.id);
              } else {
                _selectedIds.add(item.id);
              }
            });
            widget.onSelectionChanged?.call(_selectedIds);
          },
          child: Stack(
            children: [
              // Card + รูป + ชื่อ
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? kThemeGreen : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        child: Image.network(imageUrl, fit: BoxFit.cover),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.name ?? 'ไม่มีชื่อ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              // Checkbox มุมขวาบน
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    shape: BoxShape.circle,
                  ),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedIds.add(item.id);
                        } else {
                          _selectedIds.remove(item.id);
                        }
                      });
                      widget.onSelectionChanged?.call(_selectedIds);
                    },
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
