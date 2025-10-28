import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'package:laptop_harbor/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:laptop_harbor/screens/track_order_screen.dart';

// =============== CLASS DECLARATION AND STATE VARIABLES ===============
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';
  bool _isLoading = false;
  bool _orderPlaced = false;
  String? _orderId; // Store the order ID

  User? _currentUser;
  String? _userName;

  // =============== INIT STATE METHOD ===============
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    // Pre-fill user data if available
    if (_currentUser != null) {
      _fetchUserData();
    }
  }

  // =============== FETCH USER DATA METHOD ===============
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = userData['name'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _cityController.text = userData['city'] ?? '';
          _postalCodeController.text = userData['postalCode'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _userName = userData['name'] ?? '';
        });
      } else {
        if (_currentUser?.displayName != null) {
          setState(() {
            _nameController.text = _currentUser!.displayName!;
            _userName = _currentUser!.displayName!;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading your information: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // =============== COPY ORDER ID FUNCTION ===============
  void _copyOrderId(String orderId) {
    Clipboard.setData(ClipboardData(text: orderId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order ID copied to clipboard!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // =============== UPDATE STOCK FUNCTION ===============
  Future<void> _updateProductStock() async {
    final cartItems = Cart.instance.items;

    for (var productId in cartItems.keys) {
      final item = cartItems[productId]!;

      try {
        // Get the product document
        DocumentSnapshot productDoc = await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          // Get current stock and ensure it's an integer
          int currentStock = int.tryParse(productDoc['stock'].toString()) ?? 0;

          // Get ordered quantity and ensure it's an integer
          int orderedQuantity = int.tryParse(item['quantity'].toString()) ?? 0;

          // Calculate new stock
          int newStock = currentStock - orderedQuantity;

          // Update the stock in Firestore
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .update({'stock': newStock});

          print(
            "Updated stock for ${item['name']}: $currentStock -> $newStock",
          );
        }
      } catch (e) {
        print("Error updating stock for $productId: $e");
      }
    }
  }

  // =============== DISPOSE METHOD ===============
  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // =============== PLACE ORDER METHOD ===============
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_currentUser != null) {
        final cartItems = Cart.instance.items;
        final subtotal = Cart.instance.getTotalPrice();
        final deliveryFee = 100.0;
        final total = subtotal + deliveryFee;

        DocumentReference orderRef = await FirebaseFirestore.instance
            .collection('orders')
            .add({
              'userId': _currentUser!.uid,
              'userName': _nameController.text.isNotEmpty
                  ? _nameController.text
                  : (_userName ?? 'Guest'),
              'userEmail': _currentUser!.email,
              'userAddress': _addressController.text,
              'userCity': _cityController.text,
              'userPhone': _phoneController.text,
              'products': cartItems.values
                  .map(
                    (item) => {
                      'id': item['id'],
                      'name': item['name'],
                      'price': item['price'],
                      'quantity': item['quantity'],
                      'imageUrl': item['imageUrl'],
                      'brand': item['brand'] ?? '',
                    },
                  )
                  .toList(),
              'totalAmount': total,
              'shippingAddress': {
                'name': _nameController.text,
                'address': _addressController.text,
                'city': _cityController.text,
                'postalCode': _postalCodeController.text,
                'phone': _phoneController.text,
              },
              'paymentMethod': _paymentMethod,
              'status': 'Pending',
              'createdAt': FieldValue.serverTimestamp(),
            });

        final orderId = orderRef.id;
        setState(() {
          _orderId = orderId;
        });

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .update({
                'name': _nameController.text,
                'address': _addressController.text,
                'city': _cityController.text,
                'postalCode': _postalCodeController.text,
                'phone': _phoneController.text,
              });
        } else {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_currentUser!.uid)
              .set({
                'name': _nameController.text,
                'email': _currentUser!.email,
                'address': _addressController.text,
                'city': _cityController.text,
                'postalCode': _postalCodeController.text,
                'phone': _phoneController.text,
                'createdAt': FieldValue.serverTimestamp(),
              });
        }

        for (var productId in cartItems.keys) {
          final item = cartItems[productId]!;
          await FirebaseFirestore.instance.collection('order_items').add({
            'orderId': orderId,
            'userId': _currentUser!.uid,
            'productId': productId,
            'productName': item['name'],
            'productBrand': item['brand'] ?? '',
            'price': item['price'],
            'quantity': item['quantity'],
            'imageUrl': item['imageUrl'],
            'orderDate': FieldValue.serverTimestamp(),
          });
        }

        // UPDATE PRODUCT STOCK - NEW CODE
        await _updateProductStock();

        Cart.instance.clear();

        setState(() {
          _isLoading = false;
          _orderPlaced = true;
        });

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("Order Placed!"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 50),
                const SizedBox(height: 16),
                Text(
                  "Your order has been placed successfully.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Order ID: $orderId",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.main,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _copyOrderId(orderId),
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy Order ID',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackOrderScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.main,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 40),
                  ),
                  child: Text('Track My Order'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text("Continue Shopping"),
              ),
            ],
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });

        // Show login required message
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Required"),
            content: const Text("Please login to place an order."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Login"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // - Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error placing order: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: "Retry",
            textColor: Colors.white,
            onPressed: () {
              _placeOrder();
            },
          ),
        ),
      );
    }
  }

  // =============== BUILD METHOD ===============
  @override
  Widget build(BuildContext context) {
    final cartItems = Cart.instance.items;
    final subtotal = Cart.instance.getTotalPrice();
    final deliveryFee = 100.0;
    final total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Checkout",
          style: GoogleFonts.orbitron(
            color: AppColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.dark),
        elevation: 0,
      ),
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Processing your order..."),
                ],
              ),
            )
          : _orderPlaced
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Order Placed Successfully!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Thank you for your purchase",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  // Order ID with copy button
                  if (_orderId != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Order ID: $_orderId",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.main,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyOrderId(_orderId!),
                            icon: const Icon(Icons.copy, size: 18),
                            tooltip: 'Copy Order ID',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Track My Order Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackOrderScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Track My Order'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text("Continue Shopping"),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======== Order Summary ========
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Order Summary",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final productId = cartItems.keys.elementAt(index);
                            final item = cartItems[productId]!;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item['imageUrl'],
                                      width: 65,
                                      height: 65,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 65,
                                              height: 65,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 28,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "Qty: ${item['quantity']} × Rs. ${item['price']}",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "Rs. ${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(
                          height: 25,
                          thickness: 1,
                          color: Color(0xFFECECEC),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Subtotal",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Rs. ${subtotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Delivery Fee",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "Rs. 100",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(
                          height: 25,
                          thickness: 1,
                          color: Color(0xFFECECEC),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Rs. ${total.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.main,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // ======== Order Summary End ========

                  // ========= Shipping Information - PREMIUM UI =========
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.main.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: AppColors.main,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Customer Information",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: AppColors.main,
                                size: 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your name';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Shipping Address Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.main.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.main,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Shipping Address",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Address
                          TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              labelText: "Street Address",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.home_outlined,
                                color: AppColors.main,
                                size: 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your address';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // City & Postal Code
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _cityController,
                                  decoration: InputDecoration(
                                    labelText: "City",
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.location_city_outlined,
                                      color: AppColors.main,
                                      size: 22,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Please enter your city';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _postalCodeController,
                                  decoration: InputDecoration(
                                    labelText: "Postal Code",
                                    labelStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.local_post_office_outlined,
                                      color: AppColors.main,
                                      size: 22,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Please enter postal code';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: "Phone Number",
                              labelStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.main,
                                size: 22,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please enter your phone number';
                              if (value.length < 10)
                                return 'Please enter a valid phone number';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ========= Shipping Information - PREMIUM UI End =========

                  // ======== Payment Method - ONLY COD ========
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.main.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.payment,
                                color: AppColors.main,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Payment Method",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // COD payment option with improved styling
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.main.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.main.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.money,
                                color: AppColors.main,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cash on Delivery",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Pay when you receive your order",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.main,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Place Order Button with improved styling
                  Container(
                    margin: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.main,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        shadowColor: AppColors.main.withOpacity(0.3),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag),
                          SizedBox(width: 8),
                          Text(
                            "Place Order",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
