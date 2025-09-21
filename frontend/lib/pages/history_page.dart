import 'package:flutter/material.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/models/transaction_model.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // ✨ 1. เปลี่ยนเป็นตัวแปรที่สามารถเป็น null ได้ (เอา late ออกแล้วเติม ?)
  Future<List<Transaction>>? _transactionsFuture;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndFetchTransactions();
  }

  void _loadCurrentUserAndFetchTransactions() async {
    final userString = await UserStorageService().readUserData();
    if (userString != null && mounted) { // เช็ค mounted เพื่อความปลอดภัย
      final email = jsonDecode(userString)['email'];
      
      // ✨ 2. ใช้ setState เพื่ออัปเดต UI และกำหนดค่า Future
      setState(() {
        _currentUserEmail = email;
        _transactionsFuture = ApiService().getTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      // ✨ 3. เพิ่มเงื่อนไขเช็คว่า Future พร้อมใช้งานหรือยัง
      body: _transactionsFuture == null
          ? const Center(child: CircularProgressIndicator()) // ถ้ายังไม่พร้อม ให้โหลดไปก่อน
          : FutureBuilder<List<Transaction>>( // ถ้าพร้อมแล้ว ค่อยใช้ FutureBuilder
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No transaction history found.'));
                }

                final transactions = snapshot.data!;
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      currentUserEmail: _currentUserEmail!,
                    );
                  },
                );
              },
            ),
    );
  }
}

// Widget สำหรับแสดง Transaction 1 รายการ
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currentUserEmail;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currentUserEmail,
  });

  @override
  Widget build(BuildContext context) {
    // แยกไอเทมของเราและของคู่ค้า (เหมือนเดิม)
    final myItems = transaction.tradeItems
        .where((trade) => trade.item.ownerEmail == currentUserEmail)
        .map((trade) => trade.item)
        .toList();
    final theirItems = transaction.tradeItems
        .where((trade) => trade.item.ownerEmail != currentUserEmail)
        .map((trade) => trade.item)
        .toList();

    // หาอีเมลของคู่ค้า (เหมือนเดิม)
    final opponentEmail = transaction.offerEmail == currentUserEmail
        ? transaction.accepterEmail
        : transaction.offerEmail;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias, // ทำให้ขอบมน
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ส่วน Header ของ Card
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✨ 2. ครอบด้วย Column เพื่อเพิ่มวันที่ข้างใต้
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trade with: ${opponentEmail.split('@')[0]}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // ✨ 3. แสดงวันที่และเวลาที่อัปเดตล่าสุด
                    Text(
                      DateFormat('d MMM y, HH:mm').format(transaction.updatedAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Chip(
                  label: Text(transaction.status, style: const TextStyle(fontSize: 10)),
                  backgroundColor: _getStatusColor(transaction.status),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),

      
            const Divider(),
            
            // ส่วนแสดงไอเทมที่ "คุณ" เสนอ
            Text('You offered:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildItemList(myItems, context),
            
            const SizedBox(height: 12),
            
            // ส่วนแสดงไอเทมที่ "เขา" เสนอ
            Text('They offered:', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _buildItemList(theirItems, context),
          ],
        ),
      ),
    );
  }

  /// Helper widget ใหม่สำหรับสร้างรายการไอเทมพร้อมรูปภาพ
  Widget _buildItemList(List<Item> items, BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 8.0, top: 4.0),
        child: Text('- Nothing', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      );
    }

    // สร้างรายการไอเทมแต่ละชิ้น
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ชื่อไอเทม
              Text('  • ${item.name}', style: Theme.of(context).textTheme.bodyLarge),
              
              // แถวรูปภาพแนวนอน (ถ้ามี)
              if (item.itemPictures.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 70, // ความสูงของแถวรูปภาพ
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: item.itemPictures.length,
                    itemBuilder: (context, index) {
                      final imageUrl = item.itemPictures[index];
                      return Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 4.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl,
                            width: 70, // ขนาดรูปภาพ
                            height: 70,
                            fit: BoxFit.cover,
                            // แสดง loading ขณะโหลดรูป
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              );
                            },
                            // แสดง icon error ถ้าโหลดรูปไม่ได้
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error_outline, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text('(No images)', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                ),
              ]
            ],
          ),
        );
      }).toList(),
    );
  }
  // Helper สำหรับกำหนดสีของ Status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'offering':
        return Colors.blue.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }
}