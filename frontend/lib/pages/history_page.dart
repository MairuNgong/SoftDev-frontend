import 'package:flutter/material.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/models/transaction_model.dart';
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// 🎨 THEME: กำหนดค่าสีหลักตามที่คุณต้องการ
const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C); // สีเทาเข้มอมเขียว

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  Future<List<Transaction>>? _transactionsFuture;
  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndFetchTransactions();
  }

  void _loadCurrentUserAndFetchTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final userString = await UserStorageService().readUserData();
    if (userString != null && mounted) {
      final email = jsonDecode(userString)['email'];
      
      setState(() {
        _currentUserEmail = email;
        _transactionsFuture = ApiService().getTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 THEME: เปลี่ยนสีพื้นหลังของ Scaffold
      backgroundColor: kThemeBackground,
      appBar: AppBar(
        title: const Text('Trade History'),
        // 🎨 THEME: เปลี่ยนสี AppBar และสีตัวอักษร/ไอคอน
        backgroundColor: kThemeGreen,
        foregroundColor: Colors.white,
        elevation: 0, // ทำให้ดูเรียบเนียนไปกับพื้นหลัง
      ),
      body: _transactionsFuture == null
          ? const Center(child: CircularProgressIndicator(color: kThemeGreen)) // 🎨 THEME: เปลี่ยนสี Loading
          : FutureBuilder<List<Transaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kThemeGreen)); // 🎨 THEME: เปลี่ยนสี Loading
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_outlined,
                          size: 80,
                          // 🎨 THEME: เปลี่ยนสีไอคอนในหน้าว่าง
                          color: kThemeGreen.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No History Found',
                          // 🎨 THEME: เปลี่ยนสีข้อความในหน้าว่าง
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kThemeGreen),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your completed or pending trades will appear here.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
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

// ======================================================================
// Widget สำหรับแสดง Transaction 1 รายการ (ปรับสีตาม Theme)
// ======================================================================
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
    final myItems = transaction.tradeItems
        .where((trade) => trade.item.ownerEmail == currentUserEmail)
        .map((trade) => trade.item)
        .toList();
    final theirItems = transaction.tradeItems
        .where((trade) => trade.item.ownerEmail != currentUserEmail)
        .map((trade) => trade.item)
        .toList();
    final opponentEmail = transaction.offerEmail == currentUserEmail
        ? transaction.accepterEmail
        : transaction.offerEmail; //if user is offerer, opponent is accepter

    final statusInfo = _getStatusInfo(transaction.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      //  THEME: ทำให้เงาจางลง และใช้สีพื้นหลังการ์ดเป็นสีขาว
      shadowColor: Colors.black.withOpacity(0.1),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardHeader(context, opponentEmail, statusInfo),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'You Gave', Icons.arrow_upward, Colors.redAccent),
            const SizedBox(height: 8),
            _buildItemList(myItems, context),//กันในกรณีไม่มีไอเท็ม
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Icon(Icons.swap_vert_circle_outlined, color: Colors.grey, size: 28),
              ),
            ),
            // 🎨 THEME: เปลี่ยนสีไอคอน "ได้รับ" ให้เป็นสีเขียวของธีม
            _buildSectionTitle(context, 'You Received', Icons.arrow_downward, kThemeGreen),
            const SizedBox(height: 8),
            _buildItemList(theirItems, context),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, String opponentEmail, _StatusInfo statusInfo) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      // 🎨 THEME: เปลี่ยนสีไอคอนนำ
      leading: const Icon(Icons.sync_alt, color: kThemeGreen, size: 28),
      title: Text(
        'Trade with ${opponentEmail.split('@')[0]}',
        // 🎨 THEME: เปลี่ยนสีข้อความหลัก
        style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryTextColor),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('d MMM y, HH:mm').format(transaction.updatedAt),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: Chip(
        avatar: Icon(statusInfo.icon, size: 16, color: statusInfo.textColor),
        label: Text(transaction.status, style: TextStyle(color: statusInfo.textColor, fontWeight: FontWeight.w500)),
        backgroundColor: statusInfo.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
          // 🎨 THEME: เปลี่ยนสีข้อความหัวข้อ
          fontWeight: FontWeight.w600,
          color: kPrimaryTextColor,
        )),
      ],
    );
  }

  Widget _buildItemList(List<Item> items, BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 28.0),
        child: Text('Nothing', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ${item.name}', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  // 🎨 THEME: เปลี่ยนสีชื่อไอเทม
                  color: kPrimaryTextColor.withOpacity(0.9)
                )),
                if (item.itemPictures.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: item.itemPictures.length,
                      itemBuilder: (context, index) {
                        final imageUrl = item.itemPictures[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              width: 70, height: 70, fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(width: 70, height: 70, color: Colors.grey.shade200);
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 70, height: 70, color: Colors.grey.shade200,
                                  child: const Icon(Icons.error_outline, color: Colors.grey),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ]
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  _StatusInfo _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'offering':
        return _StatusInfo(
          icon: Icons.hourglass_empty,
          backgroundColor: Colors.amber.shade100,
          textColor: Colors.amber.shade800,
        );
      case 'completed':
        // 🎨 THEME: ปรับสีสถานะ 'Completed' ให้เข้ากับธีม
        return _StatusInfo(
          icon: Icons.check_circle,
          backgroundColor: const Color(0xFFE4EAE3), // สีเขียวอ่อนๆ
          textColor: kThemeGreen, // ใช้สีเขียวเข้มของธีม
        );
      case 'cancelled':
        return _StatusInfo(
          icon: Icons.cancel,
          backgroundColor: Colors.grey.shade300,
          textColor: Colors.grey.shade800,
        );
      default:
        return _StatusInfo(
          icon: Icons.help_outline,
          backgroundColor: Colors.grey.shade200,
          textColor: Colors.grey.shade700,
        );
    }
  }
}

class _StatusInfo {
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  _StatusInfo({required this.icon, required this.backgroundColor, required this.textColor});
}