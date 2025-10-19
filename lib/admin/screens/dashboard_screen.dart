import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laptop_harbor/admin/screens/brands_screen.dart';
import 'package:rxdart/rxdart.dart'; // 👈 for combineLatest
import 'package:laptop_harbor/admin/screens/orders_screen.dart';
import 'package:laptop_harbor/admin/screens/products_screen.dart';
import 'package:laptop_harbor/admin/screens/users_screen.dart';
import 'package:laptop_harbor/screens/home_screen.dart';
import '../../core/constants/app_constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: _buildAppBar(context), // 🧠 context added here
      drawer: buildAdminDrawer(context, adminUser),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderText(),
            const SizedBox(height: 20),
            _buildStatsCards(context),
            const SizedBox(height: 30),
            _buildRecentOrdersTable(context),
          ],
        ),
      ),
    );
  }

  // ======================= AppBar =======================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Admin Dashboard',
        style: TextStyle(
          fontFamily: AppFonts.primaryFont,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // 🌀 Switch to App button
        IconButton(
          tooltip: 'Switch to App',
          icon: const Icon(Icons.switch_account),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CircleAvatar(
            backgroundColor: AppColors.light.withOpacity(0.2),
            child: const Icon(Icons.person, color: AppColors.light),
          ),
        ),
      ],
    );
  }

  // ======================= Header =======================
  Widget _buildHeaderText() {
    return const Text(
      'Overview',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: AppFonts.primaryFont,
        color: AppColors.dark,
      ),
    );
  }

  // ======================= Stats Cards =======================
  Widget _buildStatsCards(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: _fetchStatsStream(),
      builder: (context, snapshot) {
        final productsCount = snapshot.hasData ? snapshot.data![0] : 0;
        final ordersCount = snapshot.hasData ? snapshot.data![1] : 0;
        final usersCount = 0; // Users collection not added yet
        final revenue = 0; // Revenue not implemented yet

        final stats = [
          {
            'title': 'Products',
            'count': productsCount,
            'icon': Icons.shopping_bag,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProductsScreen()),
              );
            },
          },
          {
            'title': 'Orders',
            'count': ordersCount,
            'icon': Icons.receipt_long,
            'onTap': () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          },
          {
            'title': 'Users',
            'count': usersCount,
            'icon': Icons.people,
            'onTap': () {
              // Future: Add UsersScreen here
            },
          },
          {
            'title': 'Revenue',
            'count': revenue,
            'icon': Icons.attach_money,
            'onTap': () {},
          },
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: stats.map((item) {
            return InkWell(
              onTap: item['onTap'] as void Function()?,
              borderRadius: BorderRadius.circular(12),
              child: _buildStatCard(
                item['title'] as String,
                item['count'].toString(),
                item['icon'] as IconData,
                context,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  /// ✅ Realtime combined stream for products & orders count using RxDart
  Stream<List<int>> _fetchStatsStream() {
    final productsStream = FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    return Rx.combineLatest2<int, int, List<int>>(
      productsStream,
      ordersStream,
      (productsCount, ordersCount) => [productsCount, ordersCount],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    BuildContext context,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.main,
            child: Icon(icon, color: AppColors.light),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.light,
                    fontSize: 14,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.light,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primaryFont,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================= Recent Orders Table =======================
  Widget _buildRecentOrdersTable(BuildContext context) {
    final ordersRef = FirebaseFirestore.instance.collection('orders');

    return StreamBuilder<QuerySnapshot>(
      stream: ordersRef
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final orders = snapshot.data!.docs;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recent Orders',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.light,
                  fontFamily: AppFonts.primaryFont,
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingTextStyle: const TextStyle(
                    color: AppColors.light,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.primaryFont,
                  ),
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: orders.map((order) {
                    final data = order.data() as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            data['id'] ?? '',
                            style: const TextStyle(color: AppColors.light),
                          ),
                        ),
                        DataCell(
                          Text(
                            data['customer'] ?? '',
                            style: const TextStyle(color: AppColors.light),
                          ),
                        ),
                        DataCell(
                          Text(
                            data['status'] ?? '',
                            style: const TextStyle(color: AppColors.light),
                          ),
                        ),
                        DataCell(
                          Text(
                            data['amount']?.toString() ?? '',
                            style: const TextStyle(color: AppColors.light),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 6,
                    shadowColor: Colors.black38,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts.primaryFont,
                    ),
                  ),
                  child: const Text('View All Orders'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ======================= ADMIN DRAWER =======================
Widget buildAdminDrawer(BuildContext context, User? adminUser) {
  return Drawer(
    width: MediaQuery.of(context).size.width,
    child: SafeArea(
      child: Column(
        children: [
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
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "Admin Panel",
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundImage: AssetImage("assets/images/admin.png"),
                ),
                title: Text(
                  adminUser?.email ?? "Admin User",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text("Administrator"),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _adminDrawerItem(
                        Icons.dashboard_outlined,
                        "Dashboard",
                        () {
                          Navigator.pop(context);
                        },
                      ),
                      const Divider(height: 1),
                      _adminDrawerItem(
                        Icons.shopping_bag_outlined,
                        "Products",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductsScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _adminDrawerItem(
                        Icons.receipt_long_outlined,
                        "Orders",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrdersScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      _adminDrawerItem(Icons.settings_outlined, "Brands", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BrandsScreen(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dark,
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

Widget _adminDrawerItem(IconData icon, String title, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
