import 'package:flutter/material.dart';
import 'package:frontend/pages/item_preview_page.dart';

const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C);

class ProfileGridSelectable extends StatefulWidget {
  final List<Map<String, dynamic>> images;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final Set<String>? initialSelectedUrls;

  const ProfileGridSelectable({
    super.key,
    required this.images,
    this.onSelectionChanged,
    this.initialSelectedUrls,
  });

  @override
  State<ProfileGridSelectable> createState() => _ProfileGridSelectableState();
}

class _ProfileGridSelectableState extends State<ProfileGridSelectable> {
  final Set<int> _selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedUrls != null) {
      for (int i = 0; i < widget.images.length; i++) {
        final id = widget.images[i]['id'].toString();
        if (widget.initialSelectedUrls!.contains(id)) {
          _selectedIndexes.add(i);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return const Center(child: Text("No items to display."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        final item = widget.images[index];
        final url = item['image'];
        final id = item['id'];
        final isSelected = _selectedIndexes.contains(index);

        return Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () async {
                // 🖼️ เปิดหน้าแสดงรายละเอียดแบบการ์ด
                final result = await Navigator.of(context, rootNavigator: false).push(
                  MaterialPageRoute(
                    builder: (_) => ItemPreviewPage(
                      item: {
                        'id': index,
                        'name': 'Preview Item $index',
                        'ItemPictures': [url],
                      },
                    ),
                  ),
                );

                if (result != null && result is Map && result['selected'] == true) {
                  setState(() => _selectedIndexes.add(index));
                } else if (result != null && result['selected'] == false) {
                  setState(() => _selectedIndexes.remove(index));
                }

                widget.onSelectionChanged?.call(
                  _selectedIndexes.map((i) => widget.images[i]['id'].toString()).toSet(),
                );
              },
              child: Hero(
                tag: 'item_$index',
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image),
                ),
              ),
            ),

            // ✅ Checkbox มุมขวาบน
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedIndexes.remove(index);
                    } else {
                      _selectedIndexes.add(index);
                    }
                    widget.onSelectionChanged?.call(
                      _selectedIndexes.map((i) => widget.images[i]['id'].toString()).toSet(),
                    );
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? kThemeGreen : Colors.grey,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
