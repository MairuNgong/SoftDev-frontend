// file: pages/home_page.dart

// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/pages/offer_creation_page.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/home/swipe_card.dart';
import '../models/login/storage_service.dart';
import '../models/user_model.dart';
import '../models/transaction_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserStorageService _storageService = UserStorageService();
  final ApiService _apiService = ApiService();
  User? _user;
  bool _isLoading = true;
  bool _isFetchingNextBatch = false;
  String _currentOption = 'FOR_YOU';
  List<String> forYouItems = [];
  List<String> requestItems = [];
  
  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันเพื่อโหลดข้อมูล User ทันทีที่หน้านี้ถูกสร้าง
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // 1. ดึงข้อมูล userString จาก Secure Storage
      // (อย่าลืมแก้ readUserData ให้ไม่ต้องรับ context ตามคำแนะนำก่อนหน้านี้)
      final userString = await _storageService
          .readUserData(); // หากยังไม่ได้แก้ ก็ส่ง context ไปก่อน

      if (userString != null) {
        // 2. แปลง String เป็น User Object ด้วย Model ที่เราสร้างไว้
        final user = User.fromString(userString);

        // 3. อัปเดต UI ด้วยข้อมูลใหม่
        setState(() {
          _user = user;
        });
        await Future.wait([
          _fetchForYou(),
          _fetchRequest(),
        ]);
      }
    } catch (e) {
      // จัดการ Error หากดึงข้อมูลไม่สำเร็จ
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load user data: $e')));
      }
    } finally {
      // ไม่ว่าจะสำเร็จหรือล้มเหลว ให้หยุดการโหลด
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchForYou({bool isRefetch = false}) async {
    if (_user == null || (isRefetch && _isFetchingNextBatch)) return; 
    final api = _apiService; 
    
    if (isRefetch && mounted) {
      setState(() {
        _isFetchingNextBatch = true;
      });
    }

    try {
        final items = await api.getForYouItems(_user!.email);
        final Set<String> currentItemIds = forYouItems.map((e) => jsonDecode(e)['id']?.toString() ?? '').toSet();
        final List<String> newUniqueItems = items.where((itemJson) {
          final itemId = jsonDecode(itemJson)['id']?.toString();
          return itemId != null && !currentItemIds.contains(itemId);
        }).toList();
        if (mounted) {
            setState(() {
            if (!isRefetch || forYouItems.isEmpty) {
                forYouItems = items;
            } else {
                forYouItems.addAll(newUniqueItems); 
            }
          });
        }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error fetching "For You" items: $e')));
        }
    } finally {
        if (mounted) {
            setState(() {
                _isFetchingNextBatch = false; 
            });
        }
    }
}

  Future<void> _fetchRequest({bool isRefetch = false}) async {
    if (_user == null || (isRefetch && _isFetchingNextBatch)) return; 
    final api = _apiService; 
    
    if (isRefetch && mounted) {
      setState(() {
        _isFetchingNextBatch = true;
      });
    }

    try {
      final List<Transaction> transactions = await api.getRequestItems(_user!.email);
      final List<String> newItemsJson = transactions
          .map((t) => t.toJsonStringForRequestCard(_user!.email))
          .toList();
      final Set<int> currentTransactionIds = requestItems
          .map((e) => jsonDecode(e)['transactionId'] as int? ?? 0)
          .toSet();
      
      final List<String> newUniqueItems = newItemsJson.where((itemJson) {
        final transactionId = jsonDecode(itemJson)['transactionId'] as int?;
        return transactionId != null && !currentTransactionIds.contains(transactionId);
      }).toList();
      if (mounted) {
          setState(() {
            if (!isRefetch || requestItems.isEmpty) {
                requestItems = newItemsJson;
            } else {
                requestItems.addAll(newUniqueItems); 
            }
          });
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching "Request" items: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingNextBatch = false; 
        });
      }
    }
  }

  void _handleLikeOffer(String likedItemJson) async {
    final likedItemData = jsonDecode(likedItemJson);
    final String likedItemId = likedItemData['id']?.toString() ?? 'unknown';
    final String likedItemName = likedItemData['name'] ?? 'Unknown Item';
    final String ownerEmail = likedItemData['ownerEmail'] ?? '';

    final int itemIndex = forYouItems.indexOf(likedItemJson);

    // เปิดหน้า OfferCreationPage
    final selectedOfferItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OfferCreationPage(
          targetItemId: likedItemId,
          targetItemName: likedItemName,
          ownerEmail: ownerEmail,
          initialSelectedItemId: likedItemId,
          selectedTargetItems: const <Map<String, dynamic>>[],
        ),
      ),
    );

    if (selectedOfferItem != null && selectedOfferItem is Map<String, dynamic>) {
      final selectedItems = selectedOfferItem['selectedItems'];

      // ✅ ป้องกัน selectedItems เป็น null หรือไม่ใช่ List
      if (selectedItems == null || selectedItems is! List) {
        print("⚠️ No items selected or invalid format, skipping offer creation");
        return;
      }

      final targetItemId =
          int.tryParse(selectedOfferItem['targetItemId'].toString()) ?? 0;

      // ✅ payload ตาม format backend
      final payload = {
        "accepterEmail": ownerEmail,
        "offerItems": selectedItems.map((e) => int.parse(e.toString())).toList(),
        "requestItems": [targetItemId],
      };

      print("🟢 CreateOffer Payload ↓↓↓");
      print(JsonEncoder.withIndent('  ').convert(payload));
      print("🟢 ----------------------");

      try {
        await _apiService.createOffer(payload);
        if (mounted) {
          if (itemIndex != -1) {
            setState(() {
              forYouItems.removeAt(itemIndex);
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Offer successfully created!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create offer: $e')),
          );
        }
      }
    } else {
      print("⚠️ Offer creation cancelled or no items selected.");
    }
  }


  void _handleRejectOffer(String itemJson) async {
    final itemData = jsonDecode(itemJson);
    final int? transactionId = itemData['transactionId'] as int?;

    // ... (logic to handle transactionId == null, call API, and remove item) ...
    if (transactionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing transaction ID.')),
        );
      }
      return;
    }

    final int itemIndex = requestItems.indexOf(itemJson);
    
    try {
      // await _apiService.rejectOffer(transactionId);
      print("🟢 Rejecting offer for transaction ID: $transactionId");
      if (mounted) {
        if (itemIndex != -1) {
          setState(() {
            requestItems.removeAt(itemIndex);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer rejected.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject offer: $e')),
        );
      }
    }
  }

  // 🟢 UPDATED: Handlers now accept a JSON string and parse the ID
  void _handleAcceptOffer(String itemJson) async {
    final itemData = jsonDecode(itemJson);
    final int? transactionId = itemData['transactionId'] as int?;
    
    // ... (logic to handle transactionId == null, call API, and remove item) ...
    if (transactionId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing transaction ID.')),
        );
      }
      return;
    }
    
    final int itemIndex = requestItems.indexOf(itemJson);

    try {
      await _apiService.acceptOffer(transactionId);
      print("🟢 Accepting offer for transaction ID: $transactionId");
      if (mounted) {
        if (itemIndex != -1) {
          setState(() {
            requestItems.removeAt(itemIndex);
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Offer accepted! Trade is complete.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to accept offer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator() // ขณะกำลังโหลดข้อมูล
            : _user != null
            ? Column(
                // เมื่อโหลดข้อมูลสำเร็จ
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OptionPage(
                        title: "REQUEST",
                        onPressed: () {
                          setState(() {
                            _currentOption = 'REQUEST';
                          });
                        },
                        textColor: _currentOption == 'REQUEST'
                            ? Color.fromARGB(255, 184, 124, 76)
                            : Color.fromARGB(255, 235, 217, 209),
                        showBadge: requestItems.isNotEmpty,
                      ),
                      Container(
                        height: 20,
                        width: 1.5,
                        color: Color.fromARGB(255, 184, 124, 76),
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      OptionPage(
                        title: "FOR YOU",
                        onPressed: () {
                          setState(() {
                            _currentOption = 'FOR_YOU';
                          });
                        },
                        textColor: _currentOption == 'FOR_YOU'
                            ? Color.fromARGB(255, 184, 124, 76)
                            : Color.fromARGB(255, 235, 217, 209),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _currentOption == 'FOR_YOU'
                          ? SwipeCard(  // For You
                              items: forYouItems,
                              key: ValueKey(forYouItems.length), 
                              onStackFinishedCallback: () => _fetchForYou(isRefetch: true),
                              onItemChangedCallback: (remainingCount) {
                                const threshold = 9;
                                if (remainingCount <= threshold && !_isFetchingNextBatch) {
                                  _fetchForYou(isRefetch: true); 
                                }
                              },
                              onLikeAction: _handleLikeOffer,
                              onNopeAction: (itemJson) async {
                                try {
                                  final itemData = jsonDecode(itemJson);
                                  final itemId = itemData['id']?.toString();
                                  if (itemId != null && _user != null) {
                                    await _apiService.postWatchedItems(_user!.email, itemId);
                                    final int itemIndex = forYouItems.indexOf(itemJson);
                                    if (itemIndex != -1) {
                                      setState(() {
                                        forYouItems.removeAt(itemIndex);
                                      });
                                    }
                                  }
                                } catch (e) {
                                  print('Error posting watched item: $e');
                                }
                              },)
                          : requestItems.isNotEmpty 
                            ? SwipeCard(
                                items: requestItems, // List of specialized JSON strings
                                key: ValueKey(requestItems.length), 
                                onStackFinishedCallback: () => _fetchRequest(isRefetch: true),
                                onItemChangedCallback: (remainingCount) {
                                  const threshold = 5;
                                  if (remainingCount <= threshold && !_isFetchingNextBatch) {
                                    _fetchRequest(isRefetch: true); 
                                  }
                                },
                                onLikeAction: _handleAcceptOffer, // Swipe Right = Accept
                                onNopeAction: _handleRejectOffer, // Swipe Left = Reject
                                customCardBuilder: _buildRequestSwipeCard,
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.import_export_outlined,
                                      size: 80,
                                      color: kThemeGreen.withValues(alpha: 50),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No Request Found',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: kThemeGreen),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Offer request from others will appear here.',
                                      style: TextStyle(color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                  ),
                  const SizedBox(height: 20),
                ],
              )
            : const Text("User data not found."), // หากไม่พบข้อมูล
      ),
    );
  }
}

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
        clipBehavior: Clip.none, // Allows the badge to go outside the Stack's bounds
        children: [
          Text(
            title, 
            style: TextStyle(color: textColor, fontSize: 15)
          ),
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

Widget _buildRequestSwipeCard(BuildContext context, String itemJson) {
    final data = jsonDecode(itemJson);
    final String otherPartyEmail = data['otherPartyEmail'] ?? 'Unknown Trader';
    final String status = data['status'] ?? 'Unknown Status';
    
    final List<dynamic> itemsToReceiveRaw = data['itemsToReceive'] ?? [];
    final List<dynamic> itemsToGiveRaw = data['itemsToGive'] ?? [];

    // Helper widget to display a horizontal list of images (remains the same)
    Widget _buildImageRow(String title, List<dynamic> itemsData) {
      if (itemsData.isEmpty) {
        return Text('$title No items found.', style: const TextStyle(color: Colors.white70));
      }
      // Determine if it should be a single-item full-width display
  final bool isSingleItem = itemsData.length == 1;
  Widget imageContent;

  if (isSingleItem) {
      // 🟢 CASE 1: Single item - Full Width
      final item = itemsData.first;
      final imageUrl = (item['ItemPictures'] as List<dynamic>?)?.firstOrNull;

      imageContent = Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl, 
                fit: BoxFit.cover, 
                errorBuilder: (c, o, s) => const Icon(Icons.broken_image)
              )
            : const Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
      );
    } else {
      // 🟢 CASE 2: Multiple items - Horizontal ListView
      imageContent = SizedBox(
        height: 200, 
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: itemsData.length,
          itemBuilder: (context, index) {
            final item = itemsData[index];
            final imageUrl = (item['ItemPictures'] as List<dynamic>?)?.firstOrNull;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                width: 200, // Fixed width for scrollable images
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl, 
                        fit: BoxFit.cover, 
                        errorBuilder: (c, o, s) => const Icon(Icons.broken_image)
                      )
                    : const Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey)),
              ),
            );
          },
        ),
      );
    }
      
      return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 184, 124, 76),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              ),
              child: Text(
                '${itemsData.length} items',
                style: const TextStyle(
                  color: Color.fromARGB(255, 247, 244, 234),
                  fontSize: 12, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        imageContent, // Render the determined content
      ],
    );
  }

    return SizedBox.expand(
      child: Container(
        // padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 116, 136, 115),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Stack(
        children: [
          // 1. Image Content (fills the entire card, with padding)
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16), // Apply padding to the scrollable content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageRow('They Request (You Give):', itemsToGiveRaw),
                  const SizedBox(height: 16),
                  _buildImageRow('They Offer (You Receive):', itemsToReceiveRaw),
                ],
              ),
            ),
          ),

          // 2. 🟢 FADE OVERLAY: positioned at the bottom, covers the content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          // 3. 🟢 HEADER TEXT: positioned at the bottom, over the fade
          Positioned(
            bottom: -6, 
            left: 16, 
            right: 16, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(color: Colors.white54, height: 20),
                Text(
                  'Trade Request from', 
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  otherPartyEmail, 
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                Text(
                  'Status: $status', 
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
                const SizedBox(height: 20),
              ]
            ),
          ),
        ],
      ),
      ),
    );
}
