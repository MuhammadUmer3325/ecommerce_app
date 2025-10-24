import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 for clipboard

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  Future<void> _refreshOrders() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  void _copyOrderId(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order ID copied: $orderId'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Orders',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _user == null
          ? const Center(child: Text("Please log in to view your orders"))
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('orders')
                  // 👇 No orderBy → no index issue
                  .where('userId', isEqualTo: _user!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading orders: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                final orders = snapshot.data!.docs;

                return RefreshIndicator(
                  onRefresh: _refreshOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final data = order.data() as Map<String, dynamic>? ?? {};

                      final orderId = order.id;
                      final status = data['status'] ?? 'Pending';
                      final total = data['totalAmount'] ?? data['total'] ?? 0;

                      DateTime createdAt = DateTime.now();
                      if (data['createdAt'] != null) {
                        if (data['createdAt'] is Timestamp) {
                          createdAt = (data['createdAt'] as Timestamp).toDate();
                        } else if (data['createdAt'] is String) {
                          createdAt =
                              DateTime.tryParse(data['createdAt']) ??
                              DateTime.now();
                        }
                      }

                      // Handle products
                      List<Map<String, dynamic>> products = [];
                      if (data['products'] != null) {
                        if (data['products'] is List) {
                          products = List<Map<String, dynamic>>.from(
                            data['products'],
                          );
                        }
                      } else if (data['items'] != null) {
                        if (data['items'] is List) {
                          products = List<Map<String, dynamic>>.from(
                            data['items'],
                          );
                        }
                      }

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ExpansionTile(
                          leading: Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.grey[700],
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Order #$orderId",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copy Order ID',
                                onPressed: () => _copyOrderId(orderId),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "Placed on: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: status == 'Completed'
                                  ? Colors.green
                                  : status == 'Pending'
                                  ? Colors.orange
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Products:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (products.isNotEmpty)
                                    ...products.map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          "• ${p['name'] ?? p['productName'] ?? 'Unknown'} x${p['quantity'] ?? 1} — Rs ${p['price'] ?? 0}",
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    const Text(
                                      "No product details available",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Total Amount: Rs $total",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            "No orders yet",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Your recent orders will show up here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
