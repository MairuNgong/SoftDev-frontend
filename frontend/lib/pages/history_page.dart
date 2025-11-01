import 'package:flutter/material.dart';
import 'package:frontend/models/login/storage_service.dart';
import 'package:frontend/models/transaction_model.dart';
import 'package:frontend/pages/rating_page.dart'; // ✨ 1. Import RatingPage
import 'package:frontend/services/api_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

// 🎨 THEME: กำหนดค่าสีหลัก
const Color kThemeGreen = Color(0xFF6D8469);
const Color kThemeBackground = Color(0xFFF1EDF2);
const Color kPrimaryTextColor = Color(0xFF3D423C);

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
    final userString = await UserStorageService().readUserData();
    if (userString != null && mounted) {
      final email = jsonDecode(userString)['email'];
      
      setState(() {
        _currentUserEmail = email;
        _transactionsFuture = ApiService().getTransactions();
      });
    }
  }

  // ✨ 2. สร้างฟังก์ชันสำหรับ Refresh ข้อมูล
  void _refreshTransactions() {
    if (_currentUserEmail != null) {
      setState(() {
        _transactionsFuture = ApiService().getTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kThemeBackground,
      // appBar: AppBar(
      //   title: const Text('Trade History'),
      //   backgroundColor: kThemeGreen,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: _transactionsFuture == null
          ? const Center(child: CircularProgressIndicator(color: kThemeGreen))
          : FutureBuilder<List<Transaction>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kThemeGreen));
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
                          color: kThemeGreen.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No History Found',
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
                
                // ✨ 3. เรียงข้อมูล Transaction จากใหม่ไปเก่า โดยใช้ updatedAt
                transactions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionCard(
                      transaction: transaction,
                      currentUserEmail: _currentUserEmail!,
                      onRated: _refreshTransactions, // ✨ 4. ส่งฟังก์ชัน refresh ไปให้ Card
                    );
                  },
                );
              },
            ),
    );
  }
}

// ======================================================================
// ✨ Widget ที่อัปเดตให้รองรับ Model ใหม่ และ Status ใหม่
// ======================================================================
class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final String currentUserEmail;
  final VoidCallback onRated; // ✨ 5. รับ Callback function

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.currentUserEmail,
    required this.onRated, // ✨ 5. เพิ่มใน constructor
  });

  @override
  Widget build(BuildContext context) {
    // ✨ ตรวจสอบว่าเราเป็นคนที่ offer หรือไม่
    final bool isCurrentUserOfferer = transaction.offerEmail == currentUserEmail;
    final bool isOffererConfirmed = transaction.isOffererConfirm ?? false;
    final bool isAccepterConfirmed = transaction.isAccepterConfirm ?? false;
    
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
        : transaction.offerEmail;
    
        print('Transaction ID: ${transaction.id}, Status: ${transaction.status}, Offerer Rating: ${transaction.offererRating}, Accepter Rating: ${transaction.accepterRating}');


    // ✨ 6. สร้าง Logic สำหรับตรวจสอบว่าจะแสดงปุ่ม Rate หรือไม่
    final String status = transaction.status.toLowerCase();
    final bool isCompletedOrCancelled = status == 'complete';
    final bool hasRated = isCurrentUserOfferer
        ? transaction.accepterRating != null  // ถ้าฉันเป็น Offerer, ให้เช็คว่า Accepter มีคะแนนหรือยัง
        : transaction.offererRating != null;   // ถ้าฉันเป็น Accepter, ให้เช็คว่า Offerer มีคะแนนหรือยัง
    final bool canRate = isCompletedOrCancelled && !hasRated;

    final statusInfo = _getStatusInfo(transaction.status, isCurrentUserOfferer);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
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
            _buildItemList(myItems, context),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(
                child: Icon(Icons.swap_vert_circle_outlined, color: Colors.grey, size: 28),
              ),
            ),
            _buildSectionTitle(context, 'You Received', Icons.arrow_downward, kThemeGreen),
            const SizedBox(height: 8),
            _buildItemList(theirItems, context),
            
            // ✨ 7. เพิ่มปุ่ม "Rate this Trade" ถ้าเงื่อนไขตรง
            if (canRate)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // ✨ 8. เมื่อกดปุ่ม ให้ Navigate ไปยัง RatingPage
                      final bool? ratingSubmitted = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (context) => RatingPage(
                            transaction: transaction,
                            currentUserEmail: currentUserEmail,
                          ),
                        ),
                      );

                      // ✨ 9. ถ้า RatingPage ส่งค่า true กลับมา ให้เรียก callback เพื่อ refresh
                      if (ratingSubmitted == true) {
                        onRated();
                      }
                    },
                    icon: const Icon(Icons.star_outline_rounded),
                    label: const Text('Rate this Trade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kThemeGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),

              if (status == 'offering' || status == 'matching')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 🔴 ปุ่ม Cancel
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Cancel Offer?"),
                                content: const Text("Are you sure you want to cancel this trade?"),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              try {
                                await ApiService().cancelTransaction(transaction.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("❌ Offer cancelled successfully.")),
                                );
                                onRated(); // refresh หน้า
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to cancel offer: $e")),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text("Cancel Offer"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12), // ระยะห่างระหว่างปุ่ม

                      // 🟢 ปุ่ม Confirm (ตอนนี้ยังไม่ทำอะไร)
                      if (status == 'matching')
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                            // 🧭 แสดง Dialog ยืนยันก่อน Confirm
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Confirm Trade?"),
                                content: const Text("Are you sure you want to confirm this trade?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("No"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text("Yes"),
                                  ),
                                ],
                              ),
                            );

                            // ✅ ถ้าผู้ใช้กดยืนยัน
                            if (confirm == true) {
                              try {
                                await ApiService().confirmTransaction(transaction.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("✅ Trade confirmed successfully.")),
                                );
                                onRated(); // refresh หน้า
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("❌ Failed to confirm trade: $e")),
                                );
                              }
                            }
                          },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text("Confirm"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kThemeGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, String opponentEmail, _StatusInfo statusInfo) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.sync_alt, color: kThemeGreen, size: 28),
      title: Text(
        'Trade with ${opponentEmail.split('@')[0]}',
        style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryTextColor),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('d MMM y, HH:mm').format(transaction.updatedAt),
        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      ),
      trailing: Chip(
        avatar: Icon(statusInfo.icon, size: 16, color: statusInfo.textColor),
        label: Text(statusInfo.label, style: TextStyle(color: statusInfo.textColor, fontWeight: FontWeight.w500)),
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
          fontWeight: FontWeight.w600,
          color: kPrimaryTextColor,
        )),
      ],
    );
  }

  void _showItemDetailDialog(BuildContext context, Item item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryTextColor,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Images
                if (item.itemPictures.isNotEmpty) ...[
                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      itemCount: item.itemPictures.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.itemPictures[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.error_outline, size: 40),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Price Range
                _buildDetailRow(Icons.attach_money, 'Price Range', item.priceRange),
                const SizedBox(height: 12),
                
                // Description
                _buildDetailRow(Icons.description_outlined, 'Description', item.description ?? 'No description'),
                const SizedBox(height: 12),
                
                // Categories
                if (item.itemCategories.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(Icons.category_outlined, size: 20, color: kThemeGreen),
                      SizedBox(width: 8),
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: kPrimaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: item.itemCategories.map((category) {
                      return Chip(
                        label: Text(category),
                        backgroundColor: kThemeGreen.withOpacity(0.1),
                        labelStyle: const TextStyle(fontSize: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Contact Information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kThemeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kThemeGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_outline, size: 20, color: kThemeGreen),
                          SizedBox(width: 8),
                          Text(
                            'Owner Contact',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: kPrimaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.ownerEmail,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: kThemeGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: kPrimaryTextColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemList(List<Item> items, BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(left: 28.0),
        child: Text('Deleted Item', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
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
                          child: GestureDetector(
                            onTap: () {
                              // เปิดหน้า detail ของ item
                              _showItemDetailDialog(context, item);
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                imageUrl, width: 70, height: 70, fit: BoxFit.cover,
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
  
_StatusInfo _getStatusInfo(String status, bool isOfferer) {
  switch (status.toLowerCase()) {
    case 'offering': // กำลังเสนอ/รอคู่
      // ✨ แยกสีตามว่าเราเป็นคนที่ offer หรือถูก offer
      if (isOfferer) {
        // เราเป็นคนที่ offer (ส่งข้อเสนอไป)
        return _StatusInfo(
          icon: Icons.send_rounded,
          backgroundColor: const Color(0xFFFFF8E1), // soft amber
          textColor: const Color(0xFFF9A825), // amber 800
          label: 'Sent Offer',
        );
      } else {
        // คนอื่น offer มาหาเรา (ได้รับข้อเสนอ)
        return _StatusInfo(
          icon: Icons.inbox_rounded,
          backgroundColor: const Color(0xFFE1F5FE), // soft light blue
          textColor: const Color(0xFF0277BD), // light blue 800
          label: 'Received Offer',
        );
      }

    case 'matching': // กำลังจับคู่
      return _StatusInfo(
        icon: Icons.autorenew_rounded,
        backgroundColor: const Color(0xFFE3F2FD), // soft blue
        textColor: const Color(0xFF1976D2), // blue 700
        label: 'Matching',
      );

    case 'complete': // เสร็จสิ้น
      return _StatusInfo(
        icon: Icons.check_circle_rounded,
        backgroundColor: const Color(0xFFE8F5E9), // soft green
        textColor: const Color(0xFF2E7D32), // green 700
        label: 'Complete',
      );

    case 'cancelled': // ยกเลิก
      return _StatusInfo(
        icon: Icons.highlight_off_rounded,
        backgroundColor: const Color(0xFFFFEBEE), // soft red
        textColor: const Color(0xFFC62828), // red 700
        label: 'Cancelled',
      );

    default: // ไม่ทราบสถานะ
      return _StatusInfo(
        icon: Icons.help_outline_rounded,
        backgroundColor: const Color(0xFFF5F5F5),
        textColor: const Color(0xFF616161),
        label: status,
      );
  }
}

}

class _StatusInfo {
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final String label;

  _StatusInfo({
    required this.icon, 
    required this.backgroundColor, 
    required this.textColor,
    required this.label,
  });
}