class Item {
  final int id;
  final String name;
  final String priceRange;
  final String description;
  final String ownerEmail;
  final List<String> itemCategories;
  final List<String> itemPictures;

  Item({
    required this.id,
    required this.name,
    required this.priceRange,
    required this.description,
    required this.ownerEmail,
    required this.itemCategories,
    required this.itemPictures,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      priceRange: json['priceRange'],
      description: json['description'] ?? '', // ป้องกันค่า null
      ownerEmail: json['ownerEmail'],
      itemCategories: List<String>.from(json['ItemCategories'] ?? []),
      itemPictures: List<String>.from(json['ItemPictures'] ?? []),
    );
  }
}

// ✨ อัปเดต ProfileResponse Model
class ProfileResponse {
  final UserProfile user;
  final List<Item> availableItems;
  final List<Item> matchingItems;
  final List<Item> completeItems;
  final bool owner;

  ProfileResponse({
    required this.user,
    required this.availableItems,
    required this.matchingItems,
    required this.completeItems,
    required this.owner,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    // ฟังก์ชันช่วยแปลง List ของ JSON ไปเป็น List ของ Item Object
    List<Item> parseItems(String key) {
      if (json[key] == null) return [];
      var list = json[key] as List;
      return list.map((i) => Item.fromJson(i)).toList();
    }

    return ProfileResponse(
      user: UserProfile.fromJson(json['user']),
      availableItems: parseItems('Available'),
      matchingItems: parseItems('Matching'),
      completeItems: parseItems('Complete'),
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
      ratingScore: (json['RatingScore'] as num?)?.toInt() ?? 0, // แก้ไขให้รองรับทั้ง int และ double
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