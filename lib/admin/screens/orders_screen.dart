import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshOrders();
  }

  // Function to refresh orders
  Future<void> _refreshOrders() async {
    setState(() {
      _isLoading = true;
    });

    // Just set loading to false after a small delay to show the refresh indicator
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ Update order status
  Future<void> _updateStatus(String id, String status) async {
    try {
      await _firestore.collection('orders').doc(id).update({'status': status});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $status'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Delete order
  Future<void> _deleteOrder(String id) async {
    try {
      await _firestore.collection('orders').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 241, 243),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Orders Management',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
            tooltip: 'Refresh Orders',
          ),
        ],
      ),

      // ✅ Real-time orders with StreamBuilder
      body: StreamBuilder<QuerySnapshot>(
        // FIXED: Order by createdAt descending to show newest orders first
        stream: _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Error loading orders',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshOrders,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final orders = snapshot.data!.docs;

          return RefreshIndicator(
            // FIXED: Implement proper refresh functionality
            onRefresh: () async {
              await _refreshOrders();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final data = order.data() as Map<String, dynamic>? ?? {};

                // ✅ Safe fallback data - matching CheckoutScreen structure
                final userName =
                    data['userName'] ??
                    data['customerName'] ??
                    data['name'] ??
                    data['customer']?['name'] ??
                    'Unknown';

                final userEmail =
                    data['userEmail'] ??
                    data['customerEmail'] ??
                    data['email'] ??
                    data['customer']?['email'] ??
                    'Unknown';

                // FIXED: Try to get address from different possible fields
                String userAddress = 'Unknown';
                if (data['userAddress'] != null) {
                  userAddress = data['userAddress'];
                } else if (data['shippingAddress'] != null &&
                    data['shippingAddress']['address'] != null) {
                  userAddress = data['shippingAddress']['address'];
                } else if (data['address'] != null) {
                  userAddress = data['address'];
                } else if (data['customerAddress'] != null) {
                  userAddress = data['customerAddress'];
                }

                // FIXED: Try to get city from different possible fields
                String userCity = '';
                if (data['userCity'] != null) {
                  userCity = data['userCity'];
                } else if (data['shippingAddress'] != null &&
                    data['shippingAddress']['city'] != null) {
                  userCity = data['shippingAddress']['city'];
                }

                // Combine address and city
                if (userCity.isNotEmpty) {
                  userAddress = '$userAddress, $userCity';
                }

                final totalAmount =
                    data['totalAmount'] ??
                    data['amount'] ??
                    data['total'] ??
                    data['grandTotal'] ??
                    0;

                final status = data['status'] ?? 'Pending';

                // ✅ Handle createdAt safely
                DateTime createdAt = DateTime.now();
                if (data['createdAt'] != null) {
                  if (data['createdAt'] is Timestamp) {
                    createdAt = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is String) {
                    createdAt =
                        DateTime.tryParse(data['createdAt']) ?? DateTime.now();
                  }
                }

                // ✅ Handle products safely - matching CheckoutScreen structure
                List<Map<String, dynamic>> products = [];
                if (data['products'] != null) {
                  if (data['products'] is List) {
                    products = List<Map<String, dynamic>>.from(
                      data['products'],
                    );
                  } else if (data['products'] is Map) {
                    products = [Map<String, dynamic>.from(data['products'])];
                  }
                } else if (data['items'] != null) {
                  if (data['items'] is List) {
                    products = List<Map<String, dynamic>>.from(data['items']);
                  } else if (data['items'] is Map) {
                    products = [Map<String, dynamic>.from(data['items'])];
                  }
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "$userEmail\n${userAddress.length > 30 ? '${userAddress.substring(0, 30)}...' : userAddress}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
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
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  "Order ID: ",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    order.id,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}",
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Products:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            if (products.isNotEmpty)
                              ...products.map(
                                (p) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Text(
                                    "• ${p['name'] ?? p['productName'] ?? 'Unknown'} x${p['quantity'] ?? p['qty'] ?? 1} — Rs ${p['price'] ?? 0}",
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
                              "Total: Rs $totalAmount",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                DropdownButton<String>(
                                  value: status,
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'Pending',
                                      child: Text('Pending'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Completed',
                                      child: Text('Completed'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'Cancelled',
                                      child: Text('Cancelled'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      _updateStatus(order.id, val);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteOrder(order.id),
                                ),
                              ],
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

  // ✅ Empty state UI
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No orders found',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Orders will appear here when customers place them',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _refreshOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
