import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/screens/home_screen.dart';
import 'package:laptop_harbor/screens/cart_screen.dart';
import 'package:laptop_harbor/screens/product_detail_screen.dart';
import '../../core/constants/app_constants.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({super.key});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String searchQuery = '';
  String selectedFilter = '';
  String selectedBrand = '';
  String selectedCategory = '';
  double _topFadeOpacity = 0.0;
  int _selectedIndex = 2; // Set to 2 for All Products tab

  RangeValues priceRange = const RangeValues(0, 100000);
  double minPrice = 0;
  double maxPrice = 100000;

  final List<String> filters = [
    'Filter',
    'Price Low-High',
    'Price High-Low',
    'Brand',
    'Category',
    'Price Range',
  ];

  final List<String> brands = [
    'HP',
    'Dell',
    'Asus',
    'Lenovo',
    'Apple',
    'Acer',
    'Razer',
    'Gigabyte',
    'MSI',
    'Samsung',
  ];
  final List<String> categories = ['Gaming', 'Business', 'Student', 'Budget'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _fetchPriceRange();
  }

  void _handleScroll() {
    double offset = _scrollController.offset;
    setState(() {
      _topFadeOpacity = (offset / 50).clamp(0.0, 1.0);
    });
  }

  Future<void> _fetchPriceRange() async {
    final snapshot = await _firestore.collection('products').get();
    if (snapshot.docs.isEmpty) return;

    double min = double.infinity;
    double max = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final price = (data['price'] ?? 0) is int
          ? (data['price'] as int).toDouble()
          : double.tryParse((data['price'] ?? '0').toString()) ?? 0;
      if (price < min) min = price;
      if (price > max) max = price;
    }

    setState(() {
      minPrice = min;
      maxPrice = max;
      priceRange = RangeValues(minPrice, maxPrice);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate to different screens based on index
    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1: // Cart
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        );
        break;
      case 2: // All Products (already here)
        // No need to navigate as we're already on this screen
        break;
    }
  }

  // ===================== FILTER FUNCTION =====================
  List<QueryDocumentSnapshot> _applyFilters(
    List<QueryDocumentSnapshot> allProducts,
  ) {
    List<QueryDocumentSnapshot> filtered = allProducts;

    if (selectedBrand.isNotEmpty) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['brand'] ?? '').toString().toLowerCase() ==
            selectedBrand.toLowerCase();
      }).toList();
    }

    if (selectedCategory.isNotEmpty) {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['category'] ?? '').toString().toLowerCase() ==
            selectedCategory.toLowerCase();
      }).toList();
    }

    if (selectedFilter == 'Price Low-High') {
      filtered.sort((a, b) {
        final priceA = (a['price'] ?? 0) is int
            ? a['price']
            : int.tryParse(a['price'].toString()) ?? 0;
        final priceB = (b['price'] ?? 0) is int
            ? b['price']
            : int.tryParse(b['price'].toString()) ?? 0;
        return priceA.compareTo(priceB);
      });
    } else if (selectedFilter == 'Price High-Low') {
      filtered.sort((a, b) {
        final priceA = (a['price'] ?? 0) is int
            ? a['price']
            : int.tryParse(a['price'].toString()) ?? 0;
        final priceB = (b['price'] ?? 0) is int
            ? b['price']
            : int.tryParse(b['price'].toString()) ?? 0;
        return priceB.compareTo(priceA);
      });
    }

    if (selectedFilter == 'Price Range') {
      filtered = filtered.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final price = (data['price'] ?? 0) is int
            ? (data['price'] as int).toDouble()
            : double.tryParse((data['price'] ?? '0').toString()) ?? 0;
        return price >= priceRange.start && price <= priceRange.end;
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "All Products",
          style: GoogleFonts.orbitron(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.dark),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ===================== SEARCH BAR =====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: Colors.grey[200],
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      searchQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "Search for laptops, brands...",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ===================== FILTER BUTTONS =====================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        final isSelected = selectedFilter == filter;

                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedFilter = isSelected ? '' : filter;
                              selectedBrand = '';
                              selectedCategory = '';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AppColors.main
                                : Colors.white,
                            foregroundColor: isSelected
                                ? Colors.white
                                : Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            filter,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // ===================== FILTER CONTENT LINE =====================
                  if (selectedFilter == 'Brand') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: brands.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final brand = brands[index];
                          final isActive = selectedBrand == brand;
                          return ChoiceChip(
                            label: Text(brand),
                            selected: isActive,
                            selectedColor: AppColors.main,
                            labelStyle: TextStyle(
                              color: isActive ? Colors.white : Colors.black,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedBrand = isActive ? '' : brand;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  if (selectedFilter == 'Category') ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isActive = selectedCategory == category;
                          return ChoiceChip(
                            label: Text(category),
                            selected: isActive,
                            selectedColor: AppColors.main,
                            labelStyle: TextStyle(
                              color: isActive ? Colors.white : Colors.black,
                            ),
                            onSelected: (_) {
                              setState(() {
                                selectedCategory = isActive ? '' : category;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],

                  // ===================== PRICE RANGE SLIDER =====================
                  if (selectedFilter == 'Price Range') ...[
                    const SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RangeSlider(
                          min: minPrice,
                          max: maxPrice,
                          values: priceRange,
                          labels: RangeLabels(
                            'Rs ${priceRange.start.toInt()}',
                            'Rs ${priceRange.end.toInt()}',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              priceRange = values;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Min: Rs ${priceRange.start.toInt()}'),
                            Text('Max: Rs ${priceRange.end.toInt()}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===================== PRODUCTS GRID WITH TOP FADE =====================
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double width = constraints.maxWidth;
                  int crossAxisCount = width < 500 ? 2 : (width < 900 ? 3 : 5);

                  return Stack(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('products').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          var allProducts = snapshot.data!.docs;

                          // Local search
                          var filteredProducts = allProducts.where((doc) {
                            final data = doc.data() as Map<String, dynamic>;
                            final name = (data['name'] ?? '')
                                .toString()
                                .toLowerCase();
                            final brand = (data['brand'] ?? '')
                                .toString()
                                .toLowerCase();
                            final price = (data['price'] ?? '').toString();
                            final stock = (data['stock'] ?? '').toString();
                            return name.contains(searchQuery) ||
                                brand.contains(searchQuery) ||
                                price.contains(searchQuery) ||
                                stock.contains(searchQuery);
                          }).toList();

                          filteredProducts = _applyFilters(filteredProducts);

                          if (filteredProducts.isEmpty) {
                            return const Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }

                          return GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 0.65,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product =
                                  filteredProducts[index].data()
                                      as Map<String, dynamic>;
                              final stock = product['stock'] ?? 0;
                              final imageUrl = product['imageUrl'] ?? '';
                              final productId = filteredProducts[index].id;

                              // Create product with ID for cart functionality
                              final productWithId = Map<String, dynamic>.from(
                                product,
                              );
                              productWithId['id'] = productId;

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductDetailScreen(
                                        product: productWithId,
                                      ),
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
                                        blurRadius: 6,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(16),
                                            ),
                                        child: Stack(
                                          children: [
                                            AspectRatio(
                                              aspectRatio: 1.2,
                                              child: Container(
                                                color: Colors.white,
                                                alignment: Alignment.center,
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.broken_image,
                                                          size: 40,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: stock == 0
                                                      ? Colors.redAccent
                                                      : Colors.green,
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  stock == 0
                                                      ? "Out of Stock"
                                                      : "Sale",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                            vertical: 6,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product['name'] ?? '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    product['brand'] ?? '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "Rs ${product['price']}",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.black87,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: stock == 0
                                                      ? null
                                                      : () {
                                                          // Add to cart functionality
                                                          Cart.instance.addItem(
                                                            productWithId,
                                                          );
                                                          ScaffoldMessenger.of(
                                                            context,
                                                          ).showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                "${product['name']} added to cart",
                                                              ),
                                                              duration:
                                                                  const Duration(
                                                                    seconds: 2,
                                                                  ),
                                                            ),
                                                          );
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.main,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 6,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    "Add to Cart",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // ===================== TOP FADE EFFECT =====================
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _topFadeOpacity,
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color.fromARGB(
                                      255,
                                      85,
                                      85,
                                      85,
                                    ).withOpacity(0.8),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   selectedItemColor: AppColors.main,
      //   unselectedItemColor: AppColors.hint,
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   items: const [
      //     // 🏠 Home - Left
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       activeIcon: Icon(Icons.home),
      //       label: "",
      //     ),

      //     // 🛒 Cart - Center
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.shopping_cart_outlined),
      //       activeIcon: Icon(Icons.shopping_cart),
      //       label: "",
      //     ),

      //     // 📦 All Products - Right
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.inventory_2_outlined),
      //       activeIcon: Icon(Icons.inventory_2),
      //       label: "",
      //     ),
      //   ],
      // ),
    );
  }
}
