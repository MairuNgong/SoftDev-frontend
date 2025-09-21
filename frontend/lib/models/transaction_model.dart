// file: models/transaction_model.dart

// Model ตัวที่ 3 (ในสุด): สำหรับข้อมูล Item
class Item {
  final int id;
  final String name;
  final String priceRange;
  final String ownerEmail;
  final List<String> itemCategories;
  final List<String> itemPictures;

  Item({
    required this.id,
    required this.name,
    required this.priceRange,
    required this.ownerEmail,
    required this.itemCategories,
    required this.itemPictures,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      priceRange: json['priceRange'],
      ownerEmail: json['ownerEmail'],
      itemCategories: List<String>.from(json['ItemCategories'] ?? []),
      itemPictures: List<String>.from(json['ItemPictures'] ?? []),
    );
  }
}

// Model ตัวที่ 2 (ตรงกลาง): สำหรับข้อมูล TradeItem ที่เชื่อม Transaction กับ Item
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
  final DateTime updatedAt;
  final List<TradeItem> tradeItems;

  Transaction({
    required this.id,
    required this.offerEmail,
    required this.accepterEmail,
    required this.status,
    required this.updatedAt,
    required this.tradeItems,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    // แปลง List ของ TradeItems ที่ซ้อนอยู่ข้างใน
    var tradeItemsList = json['TradeItems'] as List;
    List<TradeItem> parsedTradeItems = tradeItemsList.map((i) => TradeItem.fromJson(i)).toList();

    return Transaction(
      id: json['id'],
      offerEmail: json['offerEmail'],
      accepterEmail: json['accepterEmail'],
      status: json['status'],
      updatedAt: DateTime.parse(json['updatedAt']),
      tradeItems: parsedTradeItems,
    );
  }
}