import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // ✅ Screens for bottom nav
  final List<Widget> _screens = [
    const _HomeBody(),
    Center(child: Text("Cart Screen")),
    Center(child: Text("Profile Screen")),
    Center(child: Text("Settings Screen")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===================== APP BAR =====================
      appBar: AppBar(
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // ✅ Background white
                border: Border.all(
                  color: AppColors.hint, // ✅ Border gray
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(6), // ✅ Thoda andar jagah
              child: const Icon(
                Icons.person,
                color: AppColors.dark, // ✅ Icon ka color (Graphite)
              ),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),

        // ✅ Orbitron font applied here
        title: Text(
          "Laptop Harbor",
          style: GoogleFonts.orbitron(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),

        centerTitle: true,
        actions: [
          // 🔍 Search Button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.hint, width: 1),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.search, color: AppColors.dark),
            ),
          ),

          // 🛒 Cart Button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppColors.hint, width: 1),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.shopping_cart, color: AppColors.dark),
            ),
          ),
        ],
      ),

      // ===================== DRAWER =====================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.main), // ✅ Onyx
              child: Text(
                "Welcome User",
                style: TextStyle(
                  color: AppColors.light, // ✅ Platinum
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(leading: Icon(Icons.home), title: Text("Home")),
            ListTile(leading: Icon(Icons.shopping_cart), title: Text("Cart")),
            ListTile(leading: Icon(Icons.person), title: Text("Profile")),
            ListTile(leading: Icon(Icons.settings), title: Text("Settings")),
          ],
        ),
      ),

      // ===================== BODY =====================
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // ✅ Platinum
      body: _screens[_selectedIndex],

      // ===================== BOTTOM NAV BAR =====================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.main, // ✅ Onyx
        unselectedItemColor: AppColors.hint, // ✅ Ash
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

// ===================== HOME BODY =====================
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===================== BANNER CARD =====================
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.hint, // ✅ Graphite
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Big Sale!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255), // ✅ Platinum
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Up to 50% OFF",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 255, 255, 255), // ✅ Platinum
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ===================== Categories =====================
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.main, // ✅ Onyx
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryCard(icon: Icons.phone_iphone, label: "Mobiles"),
                _CategoryCard(icon: Icons.laptop, label: "Laptops"),
                _CategoryCard(icon: Icons.watch, label: "Watches"),
                _CategoryCard(icon: Icons.chair, label: "Furniture"),
                _CategoryCard(icon: Icons.sports_soccer, label: "Sports"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===================== Featured Products =====================
          const Text(
            "Featured Products",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.main,
            ),
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              double gridWidth = constraints.maxWidth;
              int crossAxisCount = gridWidth > 600 ? 3 : 2;

              final products = [
                {
                  "name": "Smartphone",
                  "price": "\$299",
                  "icon": Icons.phone_android,
                  "isSale": true,
                },
                {
                  "name": "Laptop",
                  "price": "\$799",
                  "icon": Icons.laptop_mac,
                  "isSale": true,
                },
                {
                  "name": "Smart Watch",
                  "price": "\$149",
                  "icon": Icons.watch,
                  "isSale": true,
                },
                {
                  "name": "Headphones",
                  "price": "\$99",
                  "icon": Icons.headphones,
                  "isSale": true,
                },
              ];

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductCard(
                    name: product["name"] as String,
                    price: product["price"] as String,
                    image: product["icon"] as IconData,
                    isSale: product["isSale"] as bool,
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

// ===================== CATEGORY CARD =====================
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CategoryCard({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.hint, // ✅ Graphite
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: const Color.fromARGB(255, 255, 255, 255),
          ), // ✅ Platinum
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255), // ✅ Platinum
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== PRODUCT CARD =====================
class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final IconData image;
  final bool isSale;
  const _ProductCard({
    required this.name,
    required this.price,
    required this.image,
    this.isSale = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.hint, // ✅ Outer Card Background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // ✅ Inner card with background image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: AssetImage("assets/images/laptop.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ✅ Foreground content (badge, text, button)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SALE Badge
                if (isSale)
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 226, 36, 36),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "SALE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Product Name
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Product Price
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                // Button
                ElevatedButton(
                  style: AppTheme.cartButtonStyle,
                  onPressed: () {},
                  child: const Text("Add to Cart"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
