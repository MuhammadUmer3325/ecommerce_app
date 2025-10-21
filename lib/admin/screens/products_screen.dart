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
  final TextEditingController stockController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String? editingDocId;
  String? selectedCategory;
  String? selectedBrand;
  String? filterCategory;
  String searchQuery = '';
  bool _isSearchVisible = false;

  final List<String> categories = ['Gaming', 'Business', 'Student', 'Budget'];

  // ===================== OPEN ADD/EDIT FORM =====================
  void _openProductForm({DocumentSnapshot? product}) async {
    // Fetch brands from Firestore
    List<String> brandsList = [];
    final brandsSnapshot = await _firestore.collection('brands').get();
    brandsList = brandsSnapshot.docs.map((e) => e['name'].toString()).toList();

    bool isFeatured = false; // 🔥 FEATURED TOGGLE STATE

    if (product != null) {
      final data = product.data() as Map<String, dynamic>;
      editingDocId = product.id;
      nameController.text = data['name'] ?? '';
      priceController.text = data['price']?.toString() ?? '';
      descriptionController.text = data['description'] ?? '';
      imageUrlController.text = data['imageUrl'] ?? '';
      stockController.text = data['stock']?.toString() ?? '0';
      selectedCategory = data['category'];
      selectedBrand = data['brand'];
      isFeatured = data['featured'] ?? false; // 🔥 Load existing value
    } else {
      editingDocId = null;
      nameController.clear();
      priceController.clear();
      descriptionController.clear();
      imageUrlController.clear();
      stockController.clear();
      selectedCategory = null;
      selectedBrand = null;
      isFeatured = false; // 🔥 Default false
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product != null ? "Edit Product" : "Add Product",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(nameController, "Product Name"),
                  const SizedBox(height: 12),

                  // Brand Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedBrand,
                    decoration: InputDecoration(
                      labelText: "Brand",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) =>
                        value == null ? "Select a brand" : null,
                    items: brandsList
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        selectedBrand = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Price & Stock in one row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          priceController,
                          "Price",
                          isNumber: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          stockController,
                          "Stock",
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _buildTextField(descriptionController, "Description"),
                  const SizedBox(height: 12),
                  _buildTextField(imageUrlController, "Image URL"),
                  const SizedBox(height: 12),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 12),

                  // 🔥 FEATURED TOGGLE
                  SwitchListTile(
                    title: const Text("Featured Product"),
                    value: isFeatured,
                    onChanged: (val) {
                      setStateDialog(() {
                        isFeatured = val;
                      });
                    },
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate() &&
                              selectedCategory != null &&
                              selectedBrand != null) {
                            final productData = {
                              'name': nameController.text.trim(),
                              'brand': selectedBrand!,
                              'price': double.parse(priceController.text),
                              'stock': int.parse(stockController.text),
                              'description': descriptionController.text.trim(),
                              'imageUrl': imageUrlController.text.trim(),
                              'category': selectedCategory!,
                              'featured': isFeatured, // 🔥 Save toggle value
                            };

                            if (editingDocId != null) {
                              await _firestore
                                  .collection('products')
                                  .doc(editingDocId)
                                  .update(productData);
                            } else {
                              await _firestore
                                  .collection('products')
                                  .add(productData);
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(product != null ? "Update" : "Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===================== TEXT FIELD BUILDER =====================
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return "Enter $label";
        if (isNumber && double.tryParse(value) == null) {
          return "Enter a valid number";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ===================== CATEGORY DROPDOWN =====================
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
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ===================== DELETE PRODUCT =====================
  void _deleteProduct(String docId) async {
    await _firestore.collection('products').doc(docId).delete();
  }

  // ===================== TOGGLE SEARCH BAR =====================
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
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
        bottom: _isSearchVisible
            ? PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        searchQuery = val.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search by name, brand, price or stock...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: Column(
        children: [
          // ===================== CATEGORY FILTER =====================
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
                      labelText: "Category",
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

          // ===================== PRODUCT LIST =====================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productsQuery.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
                    final stock = data['stock'] ?? 0;
                    final featured = data['featured'] ?? false;

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
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                data['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (stock == 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Out of Stock",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${data['brand'] ?? 'No Brand'} • ${data['category'] ?? 'Uncategorized'} • \$${data['price'] ?? '0'} • Stock: $stock",
                            ),
                            if (featured)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Featured",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
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
