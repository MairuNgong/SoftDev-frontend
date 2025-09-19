// file: models/user_profile_model.dart

// Model หลักสำหรับ Response ทั้งหมด
class ProfileResponse {
  final UserProfile user;
  final List<dynamic> items; // ตอนนี้ items เป็น array ว่างๆ, หากมีข้อมูลค่อยสร้าง Model เพิ่ม
  final bool owner;

  ProfileResponse({
    required this.user,
    required this.items,
    required this.owner,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      // ให้ UserProfile.fromJson จัดการ object 'user' ที่ซ้อนอยู่ข้างใน
      user: UserProfile.fromJson(json['user']),
      items: List<dynamic>.from(json['items']),
      owner: json['owner'],
    );
  }
}

// Model สำหรับข้อมูล user (อัปเดต field ให้ตรง)
class UserProfile {
  final String email;
  final String name;
  final String? bio; // ใช้ ? เพื่อบอกว่าค่านี้อาจเป็น null ได้
  final String? location;
  final String? profilePicture;
  final int ratingScore;
  final String? contact;
  final String? idCard;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> interestedCategories;


  UserProfile({
    required this.email,
    required this.name,
    this.bio,
    this.location,
    this.profilePicture,
    required this.ratingScore,
    this.contact,
    this.idCard,
    required this.createdAt,
    required this.updatedAt,
    required this.interestedCategories,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'],
      name: json['name'],
      bio: json['Bio'], // ชื่อ key ไม่ตรงกับ convention ทั่วไป ต้องระวัง
      location: json['Location'],
      profilePicture: json['ProfilePicture'],
      ratingScore: json['RatingScore'],
      contact: json['Contact'],
      idCard: json['IDcard'],
      createdAt: DateTime.parse(json['createdAt']), // แปลง String เป็น DateTime
      updatedAt: DateTime.parse(json['updatedAt']),
    interestedCategories: List<String>.from(json['InterestedCategories'] ?? []),

    );

    
  }

   Map<String, dynamic> toJson() { // เพิ่ม method toJson() สำหรับแปลง Object กลับเป็น JSON
    return {
      'email': email,
      'name': name,
      'Bio': bio,
      'Location': location,
      'ProfilePicture': profilePicture,
      'RatingScore': ratingScore,
      'Contact': contact,
      'IDcard': idCard,
      'InterestedCategories': interestedCategories,
      // ไม่ต้องส่ง createdAt และ updatedAt กลับไป
    };
  }
}