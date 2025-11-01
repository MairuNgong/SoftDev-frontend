import 'package:flutter/material.dart';
import 'package:frontend/pages/item_detail_page.dart';
import 'package:frontend/services/api_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // หมวดหมู่ที่เลือก
  final List<String> _categories = [
    "Art", "Books", "Cooking", "Toys", "Gaming",
    "Gym", "Music", "Photography", "Traveling",
    "Clothing", "Electronics", "Sports", "Entertainment", "Furniture"
  ];
  final List<String> _selectedCategories = [];

  // 🔍 ฟังก์ชันค้นหา
  Future<void> _performSearch() async {
    final keyword = _searchController.text.trim();
    if (keyword.isEmpty && _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a search term or select a category")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults.clear();
    });

    try {
      final results = await _apiService.searchItems(
        keyword: keyword,
        categories: _selectedCategories,
      );

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error occurred: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 239, 239),
      appBar: AppBar(
        title: const Text('Search / Filter'),
        backgroundColor: const Color(0xFF6D8469),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter item name to search...',
                filled: true,
                fillColor: const Color.fromARGB(255, 214, 214, 214),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: GestureDetector(
                  onTap: _performSearch,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6D8469),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 10),

            // Select Categories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final selected = _selectedCategories.contains(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: const Color(0xFF5B7C6E).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF5B7C6E),
                      onSelected: (bool value) {
                        setState(() {
                          if (value) {
                            _selectedCategories.add(cat);
                          } else {
                            _selectedCategories.remove(cat);
                          }
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Display loading status or results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : _searchResults.isEmpty
                          ? const Center(child: Text("No results found"))
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 3 / 4,
                              ),
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final item = _searchResults[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemDetailPage(item: item),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(12),
                                              topRight: Radius.circular(12),
                                            ),
                                          ),
                                          child: (item["ItemPictures"] != null &&
                                                  item["ItemPictures"] is List &&
                                                  item["ItemPictures"].isNotEmpty)
                                              ? ClipRRect(
                                                  borderRadius: const BorderRadius.only(
                                                    topLeft: Radius.circular(12),
                                                    topRight: Radius.circular(12),
                                                  ),
                                                  child: Image.network(
                                                    item["ItemPictures"][0],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) =>
                                                        const Icon(Icons.broken_image,
                                                            size: 60, color: Colors.grey),
                                                  ),
                                                )
                                              : const Icon(Icons.image,
                                                  size: 60, color: Color(0xFF5B7C6E)),
                                        ),
                                        const SizedBox(height: 8),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item["name"] ?? "No name",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "ราคา: ${item["priceRange"] ?? "-"}",
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
