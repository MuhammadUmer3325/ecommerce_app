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

  // ================== ADD / EDIT ORDER FORM ==================
  void _openOrderDialog({DocumentSnapshot? existingOrder}) {
    final nameController = TextEditingController(
      text: existingOrder != null ? existingOrder['userName'] ?? '' : '',
    );
    final emailController = TextEditingController(
      text: existingOrder != null ? existingOrder['userEmail'] ?? '' : '',
    );
    final addressController = TextEditingController(
      text: existingOrder != null ? existingOrder['userAddress'] ?? '' : '',
    );

    // Category & Product Selection
    String? selectedCategory;
    String? selectedProductId;
    String? selectedProductName;
    double? selectedProductPrice;

    final qtyController = TextEditingController();

    List<Map<String, dynamic>> productList = existingOrder != null
        ? List<Map<String, dynamic>>.from(existingOrder['products'])
        : [];

    // Add selected product to list
    void addProduct() {
      if (selectedProductId != null &&
          qtyController.text.isNotEmpty &&
          selectedProductPrice != null) {
        setState(() {
          productList.add({
            'productId': selectedProductId,
            'name': selectedProductName,
            'quantity': int.parse(qtyController.text.trim()),
            'price': selectedProductPrice,
            'category': selectedCategory,
          });
        });
        selectedProductId = null;
        selectedProductName = null;
        selectedProductPrice = null;
        qtyController.clear();
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text(
                existingOrder != null ? 'Edit Order' : 'Create Order',
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: _inputDecoration('Customer Name'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: _inputDecoration('Customer Email'),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: addressController,
                      decoration: _inputDecoration('Customer Address'),
                    ),
                    const SizedBox(height: 20),

                    // ================= Category Selection =================
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('products').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final products = snapshot.data!.docs;
                        final categories = products
                            .map(
                              (e) =>
                                  (e.data()
                                      as Map<String, dynamic>)['category'],
                            )
                            .toSet()
                            .toList();

                        return DropdownButtonFormField<String>(
                          value: categories.contains(selectedCategory)
                              ? selectedCategory
                              : null,
                          decoration: _inputDecoration('Select Category'),
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(cat),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedCategory = val;
                              selectedProductId = null;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 15),

                    // ================= Product Selection =================
                    if (selectedCategory != null)
                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('products')
                            .where('category', isEqualTo: selectedCategory)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final filteredProducts = snapshot.data!.docs;

                          return DropdownButtonFormField<String>(
                            value: selectedProductId,
                            decoration: _inputDecoration('Select Product'),
                            items: filteredProducts.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(data['name']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setModalState(() {
                                selectedProductId = val;
                                final doc = filteredProducts.firstWhere(
                                  (e) => e.id == val,
                                );
                                final data = doc.data() as Map<String, dynamic>;
                                selectedProductName = data['name'];
                                selectedProductPrice =
                                    double.tryParse(data['price'].toString()) ??
                                    0.0;
                              });
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 10),
                    TextFormField(
                      controller: qtyController,
                      decoration: _inputDecoration('Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),
                    if (selectedProductPrice != null)
                      Text(
                        "Price: Rs ${selectedProductPrice!.toStringAsFixed(0)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setModalState(addProduct);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Product'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ================= Product List =================
                    if (productList.isEmpty)
                      const Text(
                        'No products added yet',
                        style: TextStyle(color: Colors.grey),
                      )
                    else
                      Column(
                        children: productList.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text("${p['name']} x${p['quantity']}"),
                              subtitle: Text(
                                "Rs ${p['price']} • Category: ${p['category']}",
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    productList.remove(p);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final total = productList.fold<double>(
                      0,
                      (sum, item) =>
                          sum + (item['price'] as double) * item['quantity'],
                    );
                    final orderData = {
                      'userName': nameController.text.trim(),
                      'userEmail': emailController.text.trim(),
                      'userAddress': addressController.text.trim(),
                      'products': productList,
                      'totalAmount': total,
                      'status': 'Pending',
                      'createdAt':
                          existingOrder?['createdAt'] ?? Timestamp.now(),
                    };

                    if (existingOrder == null) {
                      await _firestore.collection('orders').add(orderData);
                    } else {
                      await _firestore
                          .collection('orders')
                          .doc(existingOrder.id)
                          .update(orderData);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                  ),
                  child: Text(existingOrder != null ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================== UPDATE STATUS ==================
  void _updateStatus(String id, String status) async {
    await _firestore.collection('orders').doc(id).update({'status': status});
  }

  // ================== DELETE ==================
  void _deleteOrder(String id) async {
    await _firestore.collection('orders').doc(id).delete();
  }

  // ================== BUILD UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 241, 243),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Orders Management'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _openOrderDialog(),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data!.docs;
          if (orders.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final products = List<Map<String, dynamic>>.from(
                data['products'],
              );
              final status = data['status'];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  title: Text("${data['userName']} (${data['userEmail']})"),
                  subtitle: Text(
                    "${data['userAddress']} • Rs ${data['totalAmount']}",
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
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
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Products:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...products.map(
                            (p) => Text(
                              "${p['name']} (${p['category']}) x${p['quantity']} - Rs ${p['price']}",
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              DropdownButton<String>(
                                value: status,
                                items: ['Pending', 'Completed', 'Cancelled']
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) _updateStatus(order.id, val);
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _openOrderDialog(existingOrder: order),
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
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.main, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
