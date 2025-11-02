// file: widgets/common/option_page.dart

import 'package:flutter/material.dart';

class OptionPage extends StatelessWidget {
  const OptionPage({
    super.key,
    required this.title,
    required this.onPressed,
    this.textColor = const Color.fromARGB(255, 184, 124, 76),
    this.showBadge = false,
  });
  final String title;
  final VoidCallback onPressed;
  final Color textColor;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Stack(
        clipBehavior:
            Clip.none, // Allows the badge to go outside the Stack's bounds
        children: [
          Text(title, style: TextStyle(color: textColor, fontSize: 15)),
          if (showBadge)
            Positioned(
              right: -10,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 228, 81, 70),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
