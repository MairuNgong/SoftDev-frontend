import 'package:flutter/material.dart';
import 'package:frontend/models/transaction_model.dart'; // ✨ 1. Import model
import 'package:frontend/models/user_profile_model.dart'; // ✨ Import user profile model
import 'package:frontend/services/api_service.dart';     // ✨ 2. Import service

// Separated Star Rating Widget for reusability and cleaner code
class StarRatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final Color selectedStarColor;
  final Color unselectedStarColor;

  const StarRatingWidget({
    super.key,
    this.rating = 0,
    required this.onRatingChanged,
    this.selectedStarColor = const Color(0xFF5B7C6E),
    this.unselectedStarColor = const Color(0xFFAABFAD),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () {
            onRatingChanged(index + 1);
          },
          icon: Icon(
            index < rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: index < rating ? selectedStarColor : unselectedStarColor,
            size: 48,
          ),
          splashRadius: 28,
        );
      }),
    );
  }
}


class RatingPage extends StatefulWidget {
  // ✨ 3. เพิ่ม properties เพื่อรับข้อมูลจากหน้า History
  final Transaction transaction;
  final String currentUserEmail;

  const RatingPage({
    super.key,
    required this.transaction,
    required this.currentUserEmail,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;
  bool _isLoading = false; // ✨ 4. เพิ่ม state สำหรับจัดการ loading
  ProfileResponse? _opponentProfile;
  bool _isLoadingProfile = true;
  
  @override
  void initState() {
    super.initState();
    _loadOpponentProfile();
  }
  
  // Load the opponent's profile
  void _loadOpponentProfile() async {
    final opponentEmail = widget.transaction.offerEmail == widget.currentUserEmail
        ? widget.transaction.accepterEmail
        : widget.transaction.offerEmail;
        
    try {
      final profile = await ApiService().getUserProfile(opponentEmail);
      if (mounted) {
        setState(() {
          _opponentProfile = profile;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load profile: $e'), backgroundColor: Colors.red),
        // );
      }
    }
  }

  // ✨ 5. สร้างฟังก์ชันสำหรับส่งข้อมูลไปที่ Backend
  void _submitRating() async {
    if (_isLoading) return; // ป้องกันการกดซ้ำ
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one star.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // เรียกใช้ ApiService
      // Ensure transactionId is an integer
      final int transactionId = widget.transaction.id is String 
          ? int.parse(widget.transaction.id as String) 
          : widget.transaction.id;
      
      await ApiService().rateTransaction(
        transactionId: transactionId,
        score: _rating.toDouble(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thank you for your feedback!'), backgroundColor: Colors.green),
        );
        // ส่งค่า true กลับไปเพื่อบอกหน้า History ว่าให้ refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✨ 6. หาข้อมูลของคู่ค้าเพื่อนำมาแสดงผล
    final opponentEmail = widget.transaction.offerEmail == widget.currentUserEmail
        ? widget.transaction.accepterEmail
        : widget.transaction.offerEmail;
    
    // ใช้รูปโปรไฟล์ของคู่ค้าถ้ามี
    final String? opponentImageUrl = _opponentProfile?.user.profilePicture;


    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF748873),
        elevation: 0,
        centerTitle: true,
        title: const Text('Rate Your Experience', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 20)),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () {
            // ✨ เพิ่ม logic ปิดหน้า
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✨ 7. แสดงรูปภาพและชื่อของคู่ค้าแบบ Dynamic จากข้อมูลโปรไฟล์
            _isLoadingProfile
                ? const SizedBox(
                    height: 100,
                    width: 100, 
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF748873),
                      ),
                    ),
                  )
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFCAD7C8),
                      border: Border.all(color: const Color(0xFF748873), width: 3),
                      image: opponentImageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(opponentImageUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: opponentImageUrl == null
                        ? const Icon(Icons.person_rounded, size: 60, color: Color(0xFF748873))
                        : null,
                  ),
            const SizedBox(height: 16),
            Text(
              _opponentProfile?.user.name ?? opponentEmail.split('@')[0], // แสดงชื่อจากโปรไฟล์ ถ้าไม่มีให้แสดงจากอีเมล
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF3B4A3D), letterSpacing: 0.5),
            ),
            _opponentProfile?.user.location != null 
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _opponentProfile!.user.location!,
                    style: TextStyle(fontSize: 16, color: Color(0xFF748873)),
                  ),
                )
              : SizedBox.shrink(),
            const SizedBox(height: 12),

            // แสดงคะแนนเรทติ้งปัจจุบันของผู้ค้า
            if (_opponentProfile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded, 
                      color: Color(0xFFF7B12C), 
                      size: 20,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Current Rating: ${_opponentProfile!.user.ratingScore}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF748873)),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF3B4A3D)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            StarRatingWidget(
              rating: _rating,
              onRatingChanged: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
              selectedStarColor: const Color(0xFFF7B12C),
              unselectedStarColor: const Color(0xFFD3D3D3),
            ),
            const SizedBox(height: 40),

            // ... (Container & TextField for comment เหมือนเดิม)

            const SizedBox(height: 40),

            // ✨ 8. เชื่อมปุ่ม Submit กับฟังก์ชัน _submitRating และจัดการ Loading
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF748873),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFF748873).withOpacity(0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                      )
                    : const Text(
                        'Submit Rating',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 0.8),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}