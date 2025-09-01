import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/history/transaction_list_item.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 mock data
    final transactions = [
      Transaction(id: "001", partner: "Ploy", time: DateTime(2025, 8, 29, 23, 13, 43)),
      Transaction(id: "002", partner: "Bank", time: DateTime.now().subtract(const Duration(hours: 1))),
      Transaction(id: "003", partner: "Nok", time: DateTime.now().subtract(const Duration(days: 1))),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("History" , style: TextStyle(color: Colors.black, fontSize: 30, fontWeight: FontWeight.bold))),
      body: ListView.separated(
        
        itemCount: transactions.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return TransactionListItem(transaction: transactions[index]);
        },
      ),
    );
  }
}
