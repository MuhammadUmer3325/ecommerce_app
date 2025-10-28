import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  String? editingDocId;

  // ============ Open Form for Add/Edit ============
  void _openUserForm({DocumentSnapshot? user}) {
    if (user != null) {
      editingDocId = user.id;
      nameController.text = user['name'];
      emailController.text = user['email'];
      phoneController.text = user['phone'] ?? '';
    } else {
      editingDocId = null;
      nameController.clear();
      emailController.clear();
      phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          user != null ? "Edit User" : "Add User",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, "Full Name"),
              const SizedBox(height: 12),
              _buildTextField(emailController, "Email", isEmail: true),
              const SizedBox(height: 12),
              _buildTextField(phoneController, "Phone"),
            ],
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
              if (_formKey.currentState!.validate()) {
                if (editingDocId != null) {
                  await _firestore
                      .collection('users')
                      .doc(editingDocId)
                      .update({
                        'name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                      });
                } else {
                  await _firestore.collection('users').add({
                    'name': nameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }
                Navigator.pop(context);
              }
            },
            child: Text(user != null ? "Update" : "Add"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isEmail = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) return "Enter $label";
        if (isEmail && !value.contains('@')) return "Enter valid email";
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============ Delete User ============
  void _deleteUser(String docId) async {
    await _firestore.collection('users').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users Management"),
        backgroundColor: AppColors.main,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "No users found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
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
                  leading: const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.main,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    user['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    user['email'] + "\n" + (user['phone'] ?? ""),
                    style: const TextStyle(fontSize: 13),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openUserForm(user: user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(user.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.main,
        onPressed: () => _openUserForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
