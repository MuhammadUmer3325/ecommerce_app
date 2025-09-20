import 'package:flutter/material.dart';
import 'home_screen.dart';


// ===================== MAIN SCREEN =====================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ===================== SELECTED INDEX =====================
  int _selectedIndex = 0;

  // ===================== SCREENS LIST =====================
  final List<Widget> _screens = const [
    HomeScreen(),
    // 👇 Future me aur screens yahan add karenge
    Center(child: Text("Cart Screen (Coming Soon)")),
    Center(child: Text("Profile Screen (Coming Soon)")),
  ];

  // ===================== ON ITEM TAP =====================
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ===================== BUILD METHOD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --------------------- APP BAR ---------------------
      appBar: AppBar(
        title: const Text("Ecommerce App"),
        centerTitle: true,
      ),

      // --------------------- DRAWER ---------------------
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green, // ✅ Theme se replace karenge later
              ),
              child: Text(
                "Drawer Header",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text("Cart"),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
            ),
          ],
        ),
      ),

      // --------------------- BODY ---------------------
      body: _screens[_selectedIndex],

      // --------------------- BOTTOM NAVIGATION ---------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
