import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/furniture_detail.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> furnitureItems = [];
  List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.all_inclusive,
      'name': 'Бүгд',
      'dbName': 'All',
      'color': Colors.deepPurple,
    },
    {
      'icon': Icons.chair_outlined,
      'name': 'Сандал',
      'dbName': 'Chair',
      'color': Colors.orange,
    },
    {
      'icon': Icons.table_restaurant_outlined,
      'name': 'Ширээ',
      'dbName': 'Tables',
      'color': Colors.green,
    },
    {
      'icon': Icons.weekend_outlined,
      'name': 'Буйдан',
      'dbName': 'Sofa',
      'color': Colors.blue,
    },
    {
      'icon': Icons.bed_outlined,
      'name': 'Ор',
      'dbName': 'Beds',
      'color': Colors.purple,
    },
    {
      'icon': Icons.kitchen_outlined,
      'name': 'Шүүгээ',
      'dbName': 'Cabinet',
      'color': Colors.brown,
    },
    {
      'icon': Icons.light_outlined,
      'name': 'Гэрэл',
      'dbName': 'Lamp',
      'color': Colors.yellow,
    },
  ];

  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFurniture();
  }

  Future<void> _fetchFurniture() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/furniture/'),
      );
      if (response.statusCode == 200) {
        setState(() {
          furnitureItems = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Тавилгуудыг ачаалахад алдаа гарлаа: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Серверт холбогдоход алдаа гарлаа: $error';
        _isLoading = false;
      });
    }
  }

  // Filter furniture items based on the selected category and search query
  List<dynamic> get _filteredFurniture {
    String searchQuery = _searchController.text.toLowerCase();

    // First filter by category if not "All"
    List<dynamic> categoryFiltered = furnitureItems;
    if (_selectedCategoryIndex > 0) {
      final selectedCategoryDbName =
          categories[_selectedCategoryIndex]['dbName'];
      categoryFiltered =
          furnitureItems.where((item) {
            return item['category']['name'] == selectedCategoryDbName;
          }).toList();
    }

    // Then filter by search query if not empty
    if (searchQuery.isNotEmpty) {
      return categoryFiltered.where((item) {
        return item['title'].toLowerCase().contains(searchQuery) ||
            item['category']['name'].toLowerCase().contains(searchQuery);
      }).toList();
    }

    return categoryFiltered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Uint8List?> _decodeBase64Image(String base64String) async {
    if (base64String == 'base64') {
      return null;
    }
    try {
      final cleanedBase64 = base64String.split(',').last;
      return base64Decode(cleanedBase64);
    } catch (e) {
      print('Зураг decode хийхэд алдаа гарлаа: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Хайлтын хэсэг
                        SizedBox(
                          height: 50,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              hintText: 'Тавилга хайх...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ангилалын хэсэг
                        const Text(
                          'Ангилал',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 90,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategoryIndex = index;
                                  });
                                },
                                child: _buildCategoryBox(
                                  categories[index]['name'],
                                  categories[index]['icon'],
                                  categories[index]['color'],
                                  isSelected: _selectedCategoryIndex == index,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Онцлох бүтээгдэхүүн
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Онцлох бүтээгдэхүүн',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Бүгдийг харах',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Бүтээгдэхүүний grid
                        _filteredFurniture.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  'Тавилга олдсонгүй',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                            : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: _filteredFurniture.length,
                              itemBuilder: (context, index) {
                                return _buildFurnitureCard(
                                  _filteredFurniture[index],
                                );
                              },
                            ),
                        const SizedBox(height: 20),

                        // Урамшуулалын баннер
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[300],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  'https://images.pexels.com/photos/584399/living-room-couch-interior-room-584399.jpeg',
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (
                                    context,
                                    child,
                                    loadingProgress,
                                  ) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value:
                                            loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                      ),
                                    );
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => Container(
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.black.withOpacity(0.3),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Хавар улирлын цуглуулга',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      '40% хүртэл хямдралтай',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 6,
                                        ),
                                        minimumSize: const Size(80, 32),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Дэлгүүр',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildCategoryBox(
    String title,
    IconData icon,
    Color color, {
    bool isSelected = false,
  }) {
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border:
                  isSelected
                      ? Border.all(color: color, width: 2)
                      : Border.all(color: Colors.transparent),
            ),
            child: Icon(
              icon,
              size: 26,
              color: isSelected ? color : Colors.grey[700],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? color : Colors.grey[700],
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    FurnitureDetail(furnitureItem: FurnitureItem.fromMap(item)),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Бүтээгдэхүүний зураг
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Container(
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: FutureBuilder<Uint8List?>(
                        future: _decodeBase64Image(item['pic']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError ||
                              snapshot.data == null) {
                            return const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          } else {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          item['is_liked'] = !item['is_liked'];
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['is_liked']
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 18,
                          color:
                              item['is_liked'] ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Бүтээгдэхүүний мэдээлэл
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          item['rating'].toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${double.parse(item['price']).toStringAsFixed(2)}₮',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
