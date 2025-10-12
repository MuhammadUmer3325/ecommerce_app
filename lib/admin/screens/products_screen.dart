import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final CollectionReference productsRef = FirebaseFirestore.instance.collection(
    'products',
  );

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String? editingDocId;
  File? _selectedImage;
  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  // ----------------- PICK IMAGE -----------------
  Future<void> _pickImage(Function setStateDialog) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      _localImagePath = pickedFile.path;
      _imageUrlController.clear();
      setStateDialog(() {});
    }
  }

  // ----------------- DELETE PRODUCT -----------------
  Future<void> _deleteProduct(String docId) async {
    await productsRef.doc(docId).delete();
  }

  // ----------------- SHOW PRODUCT DIALOG -----------------
  void _showProductDialog({DocumentSnapshot? doc}) {
    if (doc != null) {
      editingDocId = doc.id;
      _nameController.text = doc['name'];
      _priceController.text = doc['price'].toString();
      _descController.text = doc['description'];
      _imageUrlController.text = doc['image'] ?? '';
      _selectedImage = null;
      _localImagePath = null;
    } else {
      editingDocId = null;
      _nameController.clear();
      _priceController.clear();
      _descController.clear();
      _imageUrlController.clear();
      _selectedImage = null;
      _localImagePath = null;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(doc == null ? 'Add Product' : 'Edit Product'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(_nameController, 'Product Name'),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _priceController,
                    'Price',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(_descController, 'Description', maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _imageUrlController,
                    'Image URL (optional)',
                    hintText: 'Enter image URL if you have',
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(setStateDialog),
                    icon: const Icon(Icons.image),
                    label: const Text('Select Image'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedImage != null ||
                      (_imageUrlController.text.isNotEmpty))
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _imageUrlController.text,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = _nameController.text.trim();
                  final price =
                      double.tryParse(_priceController.text.trim()) ?? 0;
                  final desc = _descController.text.trim();
                  final imageUrlInput = _imageUrlController.text.trim();

                  if (name.isEmpty || desc.isEmpty) return;

                  final finalImage = _selectedImage != null
                      ? _localImagePath
                      : (imageUrlInput.isNotEmpty ? imageUrlInput : '');

                  final data = {
                    'name': name,
                    'price': price,
                    'description': desc,
                    'image': finalImage,
                  };

                  if (editingDocId == null) {
                    await productsRef.add(data);
                  } else {
                    await productsRef.doc(editingDocId).update(data);
                  }

                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                ),
                child: Text(doc == null ? 'Add' : 'Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Products'),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No products found 😶'));

          final products = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;

              final imageWidget =
                  (data['image'] != null && data['image'].toString().isNotEmpty)
                  ? (data['image'].toString().startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data['image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(data['image']),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ))
                  : const Icon(Icons.image_not_supported, size: 60);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: ListTile(
                  leading: imageWidget,
                  title: Text(
                    data['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Price: \$${data['price']}\n${data['description']}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _showProductDialog(doc: doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteProduct(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
