import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  String? editingDocId;
  String? selectedCategory;
  String? filterCategory; // 👈 Category filter ke liye

  final List<String> categories = ['Gaming', 'Business', 'Student', 'Budget'];

  void _openProductForm({DocumentSnapshot? product}) {
    if (product != null) {
      editingDocId = product.id;
      nameController.text = product['name'] ?? '';
      priceController.text = product['price']?.toString() ?? '';
      descriptionController.text = product['description'] ?? '';
      imageUrlController.text = product['imageUrl'] ?? '';
      selectedCategory = product['category'];
    } else {
      editingDocId = null;
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      imageUrlController.clear();
      selectedCategory = null;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          product != null ? "Edit Product" : "Add Product",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(nameController, "Product Name"),
                const SizedBox(height: 12),
                _buildTextField(priceController, "Price", isNumber: true),
                const SizedBox(height: 12),
                _buildTextField(descriptionController, "Description"),
                const SizedBox(height: 12),
                _buildTextField(imageUrlController, "Image URL"),
                const SizedBox(height: 12),
                _buildCategoryDropdown(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate() &&
                  selectedCategory != null) {
                final productData = {
                  'name': nameController.text.trim(),
                  'price': double.parse(priceController.text),
                  'description': descriptionController.text.trim(),
                  'imageUrl': imageUrlController.text.trim(),
                  'category': selectedCategory!,
                };

                if (editingDocId != null) {
                  await _firestore
                      .collection('products')
                      .doc(editingDocId)
                      .update(productData);
                } else {
                  await _firestore.collection('products').add(productData);
                }
                Navigator.pop(context);
              }
            },
            child: Text(product != null ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) => value!.isEmpty ? "Enter $label" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      onChanged: (value) {
        setState(() {
          selectedCategory = value;
        });
      },
      validator: (value) => value == null ? "Select a category" : null,
      items: categories
          .map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category)),
          )
          .toList(),
      decoration: InputDecoration(
        labelText: "Category",
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _deleteProduct(String docId) async {
    await _firestore.collection('products').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Query set according to filter
    Query productsQuery = _firestore.collection('products');
    if (filterCategory != null && filterCategory!.isNotEmpty) {
      productsQuery = productsQuery.where(
        'category',
        isEqualTo: filterCategory,
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 247, 250),
      appBar: AppBar(
        title: const Text("Products Management"),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ================= FILTER SECTION =================
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: filterCategory == null
                        ? AppColors.main
                        : Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      filterCategory = null;
                    });
                  },
                  child: Text(
                    "All",
                    style: TextStyle(
                      color: filterCategory == null
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: filterCategory,
                    onChanged: (value) {
                      setState(() {
                        filterCategory = value;
                      });
                    },
                    items: categories
                        .map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: "Select Category",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= PRODUCT LIST =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsQuery.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    final data = product.data() as Map<String, dynamic>;
                    final imageUrl = data['imageUrl'] ?? '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                              ),
                        title: Text(
                          data['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          "${data['category'] ?? 'Uncategorized'} • \$${data['price'] ?? '0'}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  _openProductForm(product: product),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _openProductForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
