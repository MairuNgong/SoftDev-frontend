import 'package:flutter/material.dart';

class ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  const ProfileStat({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(title, style: text.bodySmall),
      ],
    );
  }
}
