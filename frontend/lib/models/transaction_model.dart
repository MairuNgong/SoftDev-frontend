// file: models/transaction_model.dart
import 'package:collection/collection.dart';

// Model ตัวที่ 3 (ในสุด): สำหรับข้อมูล Item
class Item {
  final int id;
  final String name;
  final String priceRange;
  final String? description;      // ADDED: เพิ่ม description (อาจเป็น null)
  final String ownerEmail;
  final double? ownerRatingScore; // ADDED: เพิ่ม ownerRatingScore (อาจเป็น null)
  final List<String> itemCategories;
  final List<String> itemPictures;

  Item({
    required this.id,
    required this.name,
    required this.priceRange,
    this.description,             // ADDED
    required this.ownerEmail,
    this.ownerRatingScore,        // ADDED
    required this.itemCategories,
    required this.itemPictures,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      priceRange: json['priceRange'],
      description: json['description'], // ADDED
      ownerEmail: json['ownerEmail'],
      // ADDED: แปลงเป็น double และป้องกันค่า null
      ownerRatingScore: (json['ownerRatingScore'] as num?)?.toDouble(),
      itemCategories: List<String>.from(json['ItemCategories'] ?? []),
      itemPictures: List<String>.from(json['ItemPictures'] ?? []),
    );
  }
}

// Model ตัวที่ 2 (ตรงกลาง): สำหรับข้อมูล TradeItem ที่เชื่อม Transaction กับ Item
// ไม่มีการเปลี่ยนแปลง
class TradeItem {
  final Item item;

  TradeItem({required this.item});

  factory TradeItem.fromJson(Map<String, dynamic> json) {
    return TradeItem(
      item: Item.fromJson(json['Item']),
    );
  }
}

// Model ตัวที่ 1 (นอกสุด): สำหรับ Transaction ทั้งหมด
class Transaction {
  final int id;
  final String offerEmail;
  final String accepterEmail;
  final String status;
  final double? offererRating;  // ADDED: เพิ่ม offererRating (อาจเป็น null)
  final double? accepterRating; // ADDED: เพิ่ม accepterRating (อาจเป็น null)
  final DateTime updatedAt;
  final List<TradeItem> tradeItems;

  Transaction({
    required this.id,
    required this.offerEmail,
    required this.accepterEmail,
    required this.status,
    this.offererRating,           // ADDED
    this.accepterRating,          // ADDED
    required this.updatedAt,
    required this.tradeItems,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // ปรับปรุงให้รองรับกรณี TradeItems เป็น null
    var tradeItemsList = (json['TradeItems'] as List?) ?? [];
    List<TradeItem> parsedTradeItems = tradeItemsList.map((i) => TradeItem.fromJson(i)).toList();

    return Transaction(
      id: json['id'],
      offerEmail: json['offerEmail'],
      accepterEmail: json['accepterEmail'],
      status: json['status'],
      // ADDED: แปลงเป็น double และป้องกันค่า null
      offererRating: (json['offererRating'] as num?)?.toDouble(),
      accepterRating: (json['accepterRating'] as num?)?.toDouble(),
      updatedAt: DateTime.parse(json['updatedAt']),
      tradeItems: parsedTradeItems,
    );
  }

  Map<String, dynamic> toCardJson(String currentUserEmail) {
    if (tradeItems.isEmpty) return {};
    final itemToReceiveTradeItem = tradeItems.firstWhereOrNull(
      (ti) => ti.item.ownerEmail != currentUserEmail,
    );

    if (itemToReceiveTradeItem == null) {
      return {}; 
    }

    final Item itemToReceive = itemToReceiveTradeItem.item;
    final bool isCurrentUserTheOfferer = offerEmail == currentUserEmail;
    final String otherPartyEmail = isCurrentUserTheOfferer ? accepterEmail : offerEmail;
    final double? otherPartyRating = isCurrentUserTheOfferer ? accepterRating : offererRating;

    return {
      'transactionId': id,
      'status': status,
      
      // Other Party's details
      'otherPartyEmail': otherPartyEmail,        // New key for the other user's email
      'otherPartyRating': otherPartyRating,      // New key for the other user's rating

      // Received Item details (used for display on the card)
      'id': itemToReceive.id,
      'name': itemToReceive.name,
      'description': itemToReceive.description,
      // The swipe card uses these specific keys for pictures and categories
      'ItemPictures': itemToReceive.itemPictures,
      'ItemCategories': itemToReceive.itemCategories,

      'ownerRatingScore': itemToReceive.ownerRatingScore,
    };
  }
}

