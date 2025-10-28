import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _profileImageBase64;
  dynamic _selectedImage;
  bool _isLoading = true;
  bool _isEditing = false;

  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = userData['name'] ?? '';
            _emailController.text = userData['email'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
            _profileImageBase64 = userData['profileImage'] ?? '';
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Data fetch error: $e");
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      setState(() {
        if (kIsWeb) {
          _selectedImage = pickedFile;
        } else {
          _selectedImage = File(pickedFile.path);
        }
        _profileImageBase64 = base64String;
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      String base64String = base64Encode(imageBytes);
      setState(() {
        if (kIsWeb) {
          _selectedImage = pickedFile;
        } else {
          _selectedImage = File(pickedFile.path);
        }
        _profileImageBase64 = base64String;
      });
    }
  }

  Future<void> _updateUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> updatedData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
      };

      if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
        updatedData['profileImage'] = _profileImageBase64;
      }

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update(updatedData);
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        print("Update error: $e");
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          "My Profile",
          style: GoogleFonts.orbitron(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              onPressed: () => setState(() => _isEditing = true),
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.save, color: Colors.green),
              onPressed: _updateUserData,
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent),
              onPressed: () {
                _fetchUserData();
                setState(() {
                  _isEditing = false;
                });
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // ======= Profile Picture =======
                  GestureDetector(
                    onTap: _isEditing
                        ? () => _showImagePickerBottomSheet()
                        : null,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'profileImage',
                          child: CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _getProfileImage(),
                            child:
                                (_profileImageBase64 == null ||
                                    _profileImageBase64!.isEmpty)
                                ? const Icon(
                                    Icons.person,
                                    size: 65,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // ======= Input Fields
                  _buildInfoCard(
                    icon: Icons.person,
                    label: "Full Name",
                    controller: _nameController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.email_rounded,
                    label: "Email Address",
                    controller: _emailController,
                    enabled: false, // Email field is always disabled
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    icon: Icons.phone,
                    label: "Phone Number",
                    controller: _phoneController,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 40),

                  if (_isEditing)
                    ElevatedButton.icon(
                      onPressed: _updateUserData,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text("Save Changes"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  // === Custom input field card ===
  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: label,
                  labelStyle: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text("Gallery"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getProfileImage() {
    if (_selectedImage != null) {
      if (kIsWeb) {
        return NetworkImage(_selectedImage.path);
      } else {
        return FileImage(_selectedImage);
      }
    } else if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_profileImageBase64!));
      } catch (e) {
        print("Base64 decode error: $e");
      }
    }
    return null;
  }
}
