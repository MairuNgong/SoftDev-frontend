import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String searchQuery = ""; // เก็บข้อความที่พิมพ์

final List<Map<String, String>> items = List.generate(
    10,
    (index) => {
      "name": "Item ${index + 1}",
      "image":
          "assets/login/login_bg_2.jpg", // ใช้รูป placeholder ชั่วคราว
    },
  );

  @override
  Widget build(BuildContext context) {
    final filteredItems = items
        .where((item) =>
            item["name"]!.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Color(0xFFF0F4EF),
      appBar: AppBar(
        title: const Text('Search / Filter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ช่อง Search
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFFEBD9D1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                  color: Color(0xFF5B7C6E), // สีพื้นหลังไอคอน
                  borderRadius: BorderRadius.circular(20), // มุมโค้ง
                ),
                child: const Icon(
                  Icons.search,
                  color: Colors.white, // สีไอคอน
                ),
                )
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // อัพเดทข้อความทุกครั้งที่พิมพ์
                });
              },
            ),

            const SizedBox(height: 20),

            // แสดงผลข้อความที่พิมพ์
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3 / 4,
                 children: filteredItems.map((item){
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,

                        children: [
                          Container(
                            height: 120, // กำหนดความสูงรูปตามต้องการ
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 2), // ขอบรอบรูป
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.asset(
                                item["image"]!,
                                fit: BoxFit.cover, // ให้รูปเต็ม
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item["name"]!,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                 
                )
              )
          ],
        ),
      ),
    );
  }
}
