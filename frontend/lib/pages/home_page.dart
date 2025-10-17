// file: pages/home_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/pages/offer_creation_page.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/widgets/home/swipe_card.dart';
import '../models/login/storage_service.dart';
import '../models/user_model.dart';

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
        if (mounted) {
            setState(() {
            if (!isRefetch || forYouItems.isEmpty) {
                forYouItems = items;
            } else {
                forYouItems.addAll(items); 
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
      final items = await api.getRequestItems(_user!.email); 
      if (mounted) {
          setState(() {
            if (!isRefetch || requestItems.isEmpty) {
                requestItems = items;
            } else {
                requestItems.addAll(items); 
            }
          });
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching "Request" items: $e')));
      }
    }
  }

  void _checkAndFetchForYou(int remainingCount) {
    const threshold = 9;
    if (remainingCount <= threshold && !_isFetchingNextBatch) {
      _fetchForYou(isRefetch: true); 
    }
  }

  void _handleLikeOffer(String likedItemJson) async {
    final likedItemData = jsonDecode(likedItemJson);
    final String likedItemId = likedItemData['id']?.toString() ?? 'unknown';
    final selectedOfferItem = await Navigator.of(context).push(
      MaterialPageRoute(
        builder:(context) => OfferCreationPage(
          targetItemId: likedItemId,
          targetItemName: likedItemData['name'] ?? 'Target Item',
        ),
      )
    );

    if(selectedOfferItem != null && selectedOfferItem is Map<String, dynamic>){
      final myOfferItemId = selectedOfferItem['id'];
      try {
        await _apiService.createOffer(
          targetItemId: likedItemId,
          offeredItemId: myOfferItemId,
          userEmail: _user!.email,
        );

        if (mounted) {
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
      print('Offer creation cancelled or no item selected.');
    }
  }

  void _handleAcceptOffer(String likedItemJson){
    final likedItemData = jsonDecode(likedItemJson);
    final String likedItemId = likedItemData['id']?.toString() ?? 'unknown';
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
                            onItemChangedCallback: _checkAndFetchForYou,
                            onLikeAction: _handleLikeOffer,)
                          : SwipeCard(  // Request
                            items: requestItems,
                            key: ValueKey(requestItems.length),
                            onStackFinishedCallback: () => _fetchRequest(isRefetch: true),
                            onItemChangedCallback: _checkAndFetchForYou,
                            onLikeAction: _handleAcceptOffer,)
                      ), // Request
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
  });
  final String title;
  final VoidCallback onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(title, style: TextStyle(color: textColor, fontSize: 15)),
    );
  }
}
