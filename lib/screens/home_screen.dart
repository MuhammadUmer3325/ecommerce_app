import 'package:flutter/material.dart';
import 'package:laptop_harbor/admin/screens/dashboard_screen.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'package:laptop_harbor/screens/all_products_screen.dart';
import 'package:laptop_harbor/screens/auth/login_screen.dart';
import 'package:laptop_harbor/screens/auth/signup_screen.dart';
import 'product_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  User? _currentUser; // ✅ Track user manually

  final List<Widget> _screens = [
    const _HomeBody(),
    const Center(child: Text("Cart Screen")),
    const Center(child: Text("Profile Screen")),
  ];

  @override
  void initState() {
    super.initState();

    // 🔥 Auth listener — runs only once
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _currentUser = user;
      });
    });

    // Initial value
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavIcon(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? AppColors.main : AppColors.hint),
        const SizedBox(height: 4),
        if (isSelected)
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.main,
            ),
          ),
      ],
    );
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
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Column(
            children: [
              // 🔙 Back + Title
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.dark,
                        border: Border.all(color: AppColors.hint, width: 1),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Settings",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 👤 Profile Card
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
                          _currentUser != null
                              ? "Logged in"
                              : "Product/UI Designer",
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pushNamed(context, "/profile");
                        },
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
                          const ListTile(
                            leading: Icon(Icons.person),
                            title: Text("Profile details"),
                            trailing: Icon(Icons.chevron_right),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            leading: Icon(Icons.lock),
                            title: Text("Password"),
                            trailing: Icon(Icons.chevron_right),
                          ),
                          const Divider(height: 1),
                          const ListTile(
                            leading: Icon(Icons.notifications),
                            title: Text("Notifications"),
                            trailing: Icon(Icons.chevron_right),
                          ),
                          const Divider(height: 1),
                          SwitchListTile(
                            secondary: const Icon(Icons.dark_mode),
                            title: const Text("Dark mode"),
                            value: false,
                            onChanged: (val) {},
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
                        children: const [
                          ListTile(
                            leading: Icon(Icons.info),
                            title: Text("About application"),
                            trailing: Icon(Icons.chevron_right),
                          ),
                          Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.help),
                            title: Text("Help / FAQ"),
                            trailing: Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 👑 Only show this if the logged in user is the admin
              if (_currentUser?.email == 'admin@laptopharbor.com') ...[
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text("Admin Panel"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],

              // 🚪 Login / Signup OR Logout (STATE-based, not StreamBuilder)
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
                                final result = await Navigator.push<User?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                                if (result != null) {
                                  Navigator.pop(context);
                                }
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
                                final result = await Navigator.push<User?>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SignupScreen(),
                                  ),
                                );
                                if (result != null) {
                                  Navigator.pop(context);
                                }
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
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ===================== BODY =====================
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],

      // ===================== BOTTOM NAV BAR =====================
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
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: "",
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
          // ===================== HORIZONTAL CARDS SECTION =====================
          SizedBox(
            height: 180, // card height
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // -------- CARD 1 --------
                  Container(
                    width: 280, // fixed width for horizontal card
                    margin: const EdgeInsets.only(left: 16, right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/images/gaming_laptop_banner.png",
                        ),
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Gaming Laptops",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "High performance machines",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // -------- CARD 2 --------
                  Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/ultrabook_banner.png"),
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Ultrabooks",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Lightweight & portable",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // -------- CARD 3 --------
                  Container(
                    width: 280,
                    margin: const EdgeInsets.only(left: 8, right: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        image: AssetImage(
                          "assets/images/business_laptop_banner.png",
                        ),
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
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Business Laptops",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Reliable for office work",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ===================== FEATURED BRANDS SECTION =====================
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----- TITLE -----
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 1, vertical: 12),
                child: Text(
                  "Featured Brands",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
              ),

              // ----- BRANDS SCROLL -----
              SizedBox(
                height: 90, // brand card ka height
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),

                      // ----- BRAND 1: DELL -----
                      GestureDetector(
                        onTap: () {
                          // TODO: Dell products screen open karo
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

                      // ----- BRAND 2: HP -----
                      GestureDetector(
                        onTap: () {
                          // TODO: HP products screen
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

                      // ----- BRAND 3: LENOVO -----
                      GestureDetector(
                        onTap: () {
                          // TODO: Lenovo products screen
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

                      // ----- BRAND 4: ASUS -----
                      GestureDetector(
                        onTap: () {
                          // TODO: Asus products screen
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

          // ===================== Categories =====================
          const Text(
            "Categories",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.main,
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

          // ===================== Featured Products Section =====================
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AllProductsScreen(),
                      ),
                    );
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

                  // ✅ Responsive columns based on available width
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

                      return GestureDetector(
                        onTap: () {
                          // TODO: Navigate to Product Detail screen
                        },
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
                              // ====== Product Image + Badge ======
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

                              // ====== Product Info ======
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
                                                : () {},
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
        color: AppColors.hint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productName: name,
              productPrice: price,
              productImage: "assets/images/laptop.png",
              productDescription:
                  "This is a sample description of the $name. High performance, best for work and gaming.",
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.hint,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage("assets/images/laptop.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Foreground Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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

                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

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
      ),
    );
  }
}
