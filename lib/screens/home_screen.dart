import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===================== APP BAR =====================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF636B2F),

        // Search icon
        actions: const [
          Icon(Icons.search, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),

      // ===================== BODY =====================
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================== BANNER =====================
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFFBAC095),
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
                        color: Color(0xFF3D4127),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Up to 50% OFF",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF3D4127),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===================== CATEGORIES =====================
            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D4127),
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

            // ===================== FEATURED PRODUCTS =====================
            const Text(
              "Featured Products",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D4127),
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _ProductCard(
                  name: "Smartphone",
                  price: "\$299",
                  image: Icons.phone_android,
                  isSale: true,
                ),
                _ProductCard(
                  name: "Laptop",
                  price: "\$799",
                  image: Icons.laptop_mac,
                ),
                _ProductCard(
                  name: "Smart Watch",
                  price: "\$149",
                  image: Icons.watch,
                ),
                _ProductCard(
                  name: "Headphones",
                  price: "\$99",
                  image: Icons.headphones,
                  isSale: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ===================== CATEGORY CARD WIDGET =====================
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
        color: const Color(0xFFBAC095),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: const Color(0xFF3D4127)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3D4127),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== PRODUCT CARD WIDGET =====================
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
        color: const Color(0xFFBAC095),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSale)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4DE95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "SALE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3D4127),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 6),

            Icon(image, size: 50, color: const Color(0xFF3D4127)),

            const SizedBox(height: 10),

            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF3D4127),
              ),
            ),

            Text(
              price,
              style: const TextStyle(
                color: Color(0xFFD4DE95),
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF636B2F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {},
              child: const Text("Add to Cart"),
            ),
          ],
        ),
      ),
    );
  }
}
