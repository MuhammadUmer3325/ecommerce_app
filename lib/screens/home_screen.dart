import 'package:flutter/material.dart';
import 'package:laptop_harbor/admin/screens/dashboard_screen.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'package:laptop_harbor/screens/about_screen.dart';
import 'package:laptop_harbor/screens/all_products_screen.dart';
import 'package:laptop_harbor/screens/auth/login_screen.dart';
import 'package:laptop_harbor/screens/auth/signup_screen.dart';
import 'package:laptop_harbor/screens/cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbor/screens/help_screen.dart';
import 'package:laptop_harbor/screens/my_orders_screen.dart';
import 'package:laptop_harbor/screens/product_detail_screen.dart';
import 'package:laptop_harbor/screens/profile_detail_screen.dart';
import 'package:laptop_harbor/screens/track_order_screen.dart';
import 'dart:async';

// ===================== CART LOGIC =====================
class Cart extends ChangeNotifier {
  // Singleton instance
  static final Cart _instance = Cart._internal();
  factory Cart() => _instance;
  static Cart get instance => _instance;

  Cart._internal();

  final Map<String, Map<String, dynamic>> _items = {};
  final ValueNotifier<int> itemCountNotifier = ValueNotifier(0);

  Map<String, Map<String, dynamic>> get items => _items;

  void addItem(Map<String, dynamic> product) {
    final productId = product['id'];
    if (_items.containsKey(productId)) {
      _items[productId]!['quantity']++;
    } else {
      _items[productId] = {...product, 'quantity': 1};
    }
    itemCountNotifier.value = _items.length;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    itemCountNotifier.value = _items.length;
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
    } else if (_items.containsKey(productId)) {
      _items[productId]!['quantity'] = quantity;
      notifyListeners();
    }
  }

  double getTotalPrice() {
    double total = 0.0;
    _items.forEach((key, item) {
      total += (item['price'] as num) * item['quantity'];
    });
    return total;
  }

  void clear() {
    _items.clear();
    itemCountNotifier.value = 0;
    notifyListeners();
  }
}

// ===================== END OF CART LOGIC =====================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? _currentUser;
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  String _selectedBrand = ''; // Added to track selected brand
  String _selectedCategory = ''; // Added to track selected category

  // Changed to a getter to pass selectedBrand and selectedCategory to AllProductsScreen
  List<Widget> get _screens => [
    const _HomeBody(),
    const CartScreen(),
    AllProductsScreen(
      initialBrand: _selectedBrand,
      initialCategory: _selectedCategory,
    ),
  ];

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Reset selected brand and category when navigating to tabs other than All Products
      if (index != 2) {
        _selectedBrand = '';
        _selectedCategory = '';
      }
    });
  }

  // New method to navigate to brand products
  void _navigateToBrandProducts(String brand) {
    setState(() {
      _selectedBrand = brand;
      _selectedCategory = '';
      _selectedIndex = 2; // AllProductsScreen ka index
    });
  }

  // New method to navigate to category products
  void _navigateToCategoryProducts(String category) {
    setState(() {
      _selectedCategory = category;
      _selectedBrand = '';
      _selectedIndex = 2; // AllProductsScreen ka index
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Only show AppBar when on home screen (index 0)
      appBar: _selectedIndex == 0
          ? AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: AppColors.hint, width: 1),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: const Icon(Icons.person, color: AppColors.dark),
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              title: _isSearchVisible
                  ? Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          25,
                        ), // ✅ Fully rounded
                        border: Border.all(color: AppColors.hint, width: 1),
                      ),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.dark, // ✅ Text color dark
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(color: AppColors.hint),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.dark, // ✅ Icon dark
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.dark,
                            ),
                            onPressed: () {
                              setState(() {
                                _isSearchVisible = false;
                                _searchController.clear();
                                searchQuery = '';
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white, // ✅ White background
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: AppColors.hint,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide(
                              color: AppColors.hint,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.trim().toLowerCase();
                          });
                        },
                      ),
                    )
                  : Text(
                      "Laptop Harbor",
                      style: GoogleFonts.orbitron(
                        color: AppColors.dark,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
              centerTitle: true,
              actions: [
                // Search Icon
                if (!_isSearchVisible)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSearchVisible = true;
                        });
                      },
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.hint,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.search,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Cart Icon with Badge
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1; // Navigate to cart
                      });
                    },
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.hint,
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.shopping_cart,
                                color: AppColors.dark,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -2,
                            top: -2,
                            child: ValueListenableBuilder<int>(
                              valueListenable: Cart.instance.itemCountNotifier,
                              builder: (context, itemCount, child) {
                                return itemCount > 0
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '$itemCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null, // No AppBar for other screens
      // ================== DRAWER START =================
      drawer: _selectedIndex == 0
          ? Drawer(
              width: MediaQuery.of(context).size.width < 600
                  ? MediaQuery.of(context).size.width
                  : 400,
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      child: Row(
                        children: [
                          if (MediaQuery.of(context).size.width < 600)
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.dark,
                                border: Border.all(
                                  color: AppColors.hint,
                                  width: 1,
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width < 600
                                      ? 22
                                      : 26,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ),
                          if (MediaQuery.of(context).size.width < 600)
                            const SizedBox(width: 48),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const CircleAvatar(
                                radius: 24,
                                backgroundImage: AssetImage(
                                  "assets/images/profile.png",
                                ),
                              ),
                              title: Text(
                                _currentUser?.email ?? "Guest User",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                _currentUser != null ? "Logged in" : "Guest",
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  Navigator.pushNamed(context, "/profile"),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "My Orders",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.shopping_bag),
                                  title: const Text("My Orders"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MyOrdersScreen(),
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.track_changes),
                                  title: const Text("Track Order"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TrackOrderScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Other settings",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person),
                                  title: const Text("Profile details"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProfileDetailsScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.info),
                                  title: const Text("About application"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AboutScreen(),
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.help),
                                  title: const Text("Help / FAQ"),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HelpScreen(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (_currentUser?.email ==
                              'admin@laptopharbor.com') ...[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.admin_panel_settings),
                                title: const Text("Admin Panel"),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const DashboardScreen(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _currentUser == null
                          ? Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.login),
                                    label: const Text("Login"),
                                    onPressed: () async {
                                      final result =
                                          await Navigator.push<User?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                      if (result != null)
                                        Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.app_registration),
                                    label: const Text("Signup"),
                                    onPressed: () async {
                                      final result =
                                          await Navigator.push<User?>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const SignupScreen(),
                                            ),
                                          );
                                      if (result != null)
                                        Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.logout),
                                label: const Text("Logout"),
                                onPressed: () async =>
                                    await FirebaseAuth.instance.signOut(),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            )
          // ================== DRAWER END =================
          : null, // No drawer for other screens
      backgroundColor: Colors.white,
      body: _isSearchVisible && searchQuery.isNotEmpty
          ? _buildSearchResults()
          : _screens[_selectedIndex],

      // ======== Bottom nav =========
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.main,
        unselectedItemColor: AppColors.hint,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: "All Products",
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        final allProducts = snapshot.data!.docs;

        // Local filtering by searchQuery
        final products = allProducts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final brand = (data['brand'] ?? '').toString().toLowerCase();
          final price = (data['price'] ?? '').toString();
          final stock = (data['stock'] ?? '').toString();
          return name.contains(searchQuery) ||
              brand.contains(searchQuery) ||
              price.contains(searchQuery) ||
              stock.contains(searchQuery);
        }).toList();

        if (products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No products found for "$searchQuery"',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Found ${products.length} results for "$searchQuery"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product =
                        products[index].data() as Map<String, dynamic>;
                    final stock = product['stock'] ?? 0;
                    final imageUrl = product['imageUrl'] ?? '';
                    final productId = products[index].id;

                    return GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: stock == 0
                                          ? Colors.redAccent
                                          : Colors.green,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      stock == 0 ? "Out of Stock" : "Sale",
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
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      product['brand'] ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Center(
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: stock == 0
                                              ? null
                                              : () {
                                                  final productWithId =
                                                      Map<String, dynamic>.from(
                                                        product,
                                                      );
                                                  productWithId['id'] =
                                                      productId;
                                                  Cart.instance.addItem(
                                                    productWithId,
                                                  );

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${product['name']} added to cart!',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.main,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6,
                                            ),
                                          ),
                                          child: const Text(
                                            "Add to Cart",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
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
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final PageController _pageController = PageController(
    viewportFraction: 0.85, // Show part of previous/next page
    initialPage: 1, // Start with the first real item (not the clone)
  );
  int _currentPage = 0; // Track the current page (0, 1, or 2)
  Timer? _timer;
  bool _isAutoScrolling = true;
  bool _isUserScrolling = false; // Track if user is manually scrolling

  // Banner data
  final List<Map<String, String>> _bannerData = [
    {
      'image': "assets/images/gaming_laptop_banner.png",
      'title': "Gaming Laptops",
      'subtitle': "High performance machines",
    },
    {
      'image': "assets/images/ultrabook_banner.png",
      'title': "Ultrabooks",
      'subtitle': "Lightweight & portable",
    },
    {
      'image': "assets/images/business_laptop_banner.png",
      'title': "Business Laptops",
      'subtitle': "Reliable for office work",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll every 4 seconds
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_isAutoScrolling && _pageController.hasClients && !_isUserScrolling) {
        _nextPage();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _currentPage++;
    } else {
      _currentPage = 0;
    }
    _pageController.animateToPage(
      _currentPage + 1, // +1 because of the clone at the beginning
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
    } else {
      _currentPage = 2;
    }
    _pageController.animateToPage(
      _currentPage + 1, // +1 because of the clone at the beginning
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner section with infinite PageView
          SizedBox(
            height: 180,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollUpdateNotification) {
                  // User is manually scrolling
                  _isUserScrolling = true;

                  // Reset the auto-scroll timer when user stops scrolling
                  _timer?.cancel();
                  _timer = Timer.periodic(const Duration(seconds: 4), (
                    Timer timer,
                  ) {
                    if (_isAutoScrolling &&
                        _pageController.hasClients &&
                        !_isUserScrolling) {
                      _nextPage();
                    }
                  });

                  // Reset user scrolling flag after a delay
                  Timer(const Duration(milliseconds: 500), () {
                    _isUserScrolling = false;
                  });

                  // Handle page changes
                  if (_pageController.page == 0) {
                    // We're at the clone of the last item, jump to the real last item
                    _pageController.jumpToPage(3);
                    _currentPage = 2;
                  } else if (_pageController.page == 4) {
                    // We're at the clone of the first item, jump to the real first item
                    _pageController.jumpToPage(1);
                    _currentPage = 0;
                  } else {
                    // Update current page based on the page controller
                    _currentPage = (_pageController.page! - 1).round();
                  }
                }
                return false;
              },
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  // This is called when the user manually changes the page
                  if (page == 0) {
                    // We're at the clone of the last item
                    setState(() {
                      _currentPage = 2;
                    });
                  } else if (page == 4) {
                    // We're at the clone of the first item
                    setState(() {
                      _currentPage = 0;
                    });
                  } else {
                    // Update current page based on the page controller
                    setState(() {
                      _currentPage = page - 1;
                    });
                  }
                },
                itemCount: 5, // 3 real items + 2 clones for infinite scrolling
                itemBuilder: (context, index) {
                  // Get the actual banner index (0, 1, or 2)
                  int bannerIndex = index;
                  if (index == 0) {
                    // First clone - show the last banner
                    bannerIndex = 2;
                  } else if (index == 4) {
                    // Last clone - show the first banner
                    bannerIndex = 0;
                  } else {
                    // Real banner
                    bannerIndex = index - 1;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: AssetImage(_bannerData[bannerIndex]['image']!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _bannerData[bannerIndex]['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _bannerData[bannerIndex]['subtitle']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Page indicators (dots)
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.main
                      : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),
          // ====================== TOP BRANDS ======================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                child: Text(
                  "Top Brands",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
              ),
              SizedBox(
                height: 90,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          // Use the new method instead of Navigator.push
                          final homeScreenState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeScreenState?._navigateToBrandProducts("Dell");
                        },
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              "assets/brands/dell_logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Use the new method instead of Navigator.push
                          final homeScreenState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeScreenState?._navigateToBrandProducts("HP");
                        },
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              "assets/brands/hp_logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Use the new method instead of Navigator.push
                          final homeScreenState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeScreenState?._navigateToBrandProducts("Lenovo");
                        },
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              "assets/brands/lenovo_logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Use the new method instead of Navigator.push
                          final homeScreenState = context
                              .findAncestorStateOfType<_HomeScreenState>();
                          homeScreenState?._navigateToBrandProducts("Asus");
                        },
                        child: Container(
                          width: 90,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              "assets/brands/asus_logo.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ====================== TOP BRANDS END ======================

          // ======================= CATEGORIES =======================
          const Text(
            "Laptop Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90, // Reduced from 120 to 90
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _LaptopCategoryCard(
                  icon: Icons.sports_esports,
                  label: "Gaming",
                  color: Color(0xFF6A11CB),
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    final homeScreenState = context
                        .findAncestorStateOfType<_HomeScreenState>();
                    homeScreenState?._navigateToCategoryProducts("Gaming");
                  },
                ),
                _LaptopCategoryCard(
                  icon: Icons.business_center,
                  label: "Business",
                  color: Color(0xFF2193B0),
                  gradient: LinearGradient(
                    colors: [Color(0xFF2193B0), Color(0xFF6DD5ED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    final homeScreenState = context
                        .findAncestorStateOfType<_HomeScreenState>();
                    homeScreenState?._navigateToCategoryProducts("Business");
                  },
                ),
                _LaptopCategoryCard(
                  icon: Icons.school,
                  label: "Students",
                  color: Color(0xFF3F2B96),
                  gradient: LinearGradient(
                    colors: [Color(0xFF3F2B96), Color(0xFFA8C0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    final homeScreenState = context
                        .findAncestorStateOfType<_HomeScreenState>();
                    homeScreenState?._navigateToCategoryProducts("Student");
                  },
                ),
                _LaptopCategoryCard(
                  icon: Icons.savings,
                  label: "Budget",
                  color: Color(0xFF11998E),
                  gradient: LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    final homeScreenState = context
                        .findAncestorStateOfType<_HomeScreenState>();
                    homeScreenState?._navigateToCategoryProducts("Budget");
                  },
                ),
              ],
            ),
          ),

          // ======================= CATEGORIES END =======================
          const SizedBox(height: 24),
          // =============== FEATURED PRODUCTS START ===============
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Featured Products",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.main,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Find the HomeScreen state and navigate to AllProducts
                    final homeScreenState = context
                        .findAncestorStateOfType<_HomeScreenState>();
                    homeScreenState?._onItemTapped(
                      2,
                    ); // 2 is the index for AllProducts
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    backgroundColor: AppColors.main,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where('featured', isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No featured products found'));
              }
              final products = snapshot.data!.docs;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  int crossAxisCount = 2;
                  if (screenWidth > 1200) {
                    crossAxisCount = 5;
                  } else if (screenWidth > 900) {
                    crossAxisCount = 4;
                  } else if (screenWidth > 600) {
                    crossAxisCount = 3;
                  }
                  const double spacing = 12;
                  final double cardWidth =
                      (screenWidth - ((crossAxisCount - 1) * spacing)) /
                      crossAxisCount;
                  final double cardHeight = cardWidth * 1.45;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      childAspectRatio: cardWidth / cardHeight,
                    ),
                    itemBuilder: (context, index) {
                      final product =
                          products[index].data() as Map<String, dynamic>;
                      final stock = product['stock'] ?? 0;
                      final imageUrl = product['imageUrl'] ?? '';
                      final productId = products[index].id;

                      // Create product with ID for cart functionality
                      final productWithId = Map<String, dynamic>.from(product);
                      productWithId['id'] = productId;

                      return GestureDetector(
                        onTap: () {
                          // Navigate to product detail page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailScreen(product: productWithId),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              // Main shadow with more depth
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                              // Secondary shadow for more depth
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                                spreadRadius: -2,
                              ),
                              // Bottom shadow specifically
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                                spreadRadius: -3,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      imageUrl,
                                      width: double.infinity,
                                      height: cardHeight * 0.5,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              height: cardHeight * 0.5,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: stock == 0
                                            ? Colors.redAccent
                                            : Colors.green,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        stock == 0 ? "Out of Stock" : "Sale",
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
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['name'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: screenWidth < 400 ? 12 : 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        product['brand'] ?? '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: screenWidth < 400 ? 10 : 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Rs ${product['price']}",
                                        style: TextStyle(
                                          fontSize: screenWidth < 400 ? 11 : 13,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Center(
                                        child: SizedBox(
                                          width: screenWidth < 400
                                              ? double.infinity
                                              : 110,
                                          child: ElevatedButton(
                                            onPressed: stock == 0
                                                ? null
                                                : () {
                                                    Cart.instance.addItem(
                                                      productWithId,
                                                    );

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          '${product['name']} added to cart!',
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 2,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.main,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                            ),
                                            child: Text(
                                              "Add to Cart",
                                              style: TextStyle(
                                                fontSize: screenWidth < 400
                                                    ? 11
                                                    : 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
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
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LaptopCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _LaptopCategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80, // Reduced from 100 to 80
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: gradient,
          // Removed shadow from here
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, // Reduced from 50 to 40
              height: 40, // Reduced from 50 to 40
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ), // Reduced icon size from 28 to 24
            ),
            const SizedBox(height: 8), // Reduced from 10 to 8
            Text(
              label,
              style: const TextStyle(
                fontSize: 12, // Reduced from 14 to 12
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
