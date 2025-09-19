import 'package:flutter/material.dart';
import 'package:frontend/models/category_model.dart'; // ปรับ path ให้ถูกต้อง

class CategoryCard extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
  // กำหนดสีเขียวที่เราต้องการ
  const selectedColor = Color(0xFFDCEDC8); // สีเขียวอ่อนสำหรับพื้นหลัง 
  const onSelectedColor = Color(0xFF38662A); // สีเขียวเข้มสำหรับตัวอักษร

  //  แก้ไขเงื่อนไขการใช้สี
  final color = isSelected 
      ? selectedColor // <--- เปลี่ยนเป็นสีเขียวที่กำหนดเอง
      : theme.colorScheme.surfaceVariant.withOpacity(0.5);
      
  final onColor = isSelected 
      ? onSelectedColor // <--- เปลี่ยนเป็นสีเขียวที่กำหนดเอง
      : theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(category.icon, size: 32, color: onColor),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}