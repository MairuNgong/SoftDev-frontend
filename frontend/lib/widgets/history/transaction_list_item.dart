import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return ListTile(
      leading: const Icon(Icons.swap_horiz, color: Colors.blueAccent),
      title: Text(
        "แลกของกับ ${transaction.partner}",
        style: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        DateFormat("d MMM yyyy • HH:mm").format(transaction.time),
        style: text.bodySmall,
        
      ),
      trailing: Text(
        "#${transaction.id}",
        style: text.labelMedium?.copyWith(color: Colors.grey),
      ),
    );
  }
}
