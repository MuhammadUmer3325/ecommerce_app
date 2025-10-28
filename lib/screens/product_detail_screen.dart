import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'package:laptop_harbor/screens/auth/login_screen.dart';
import 'package:laptop_harbor/screens/cart_screen.dart';
import 'package:laptop_harbor/screens/checkout_screen.dart';
import 'package:laptop_harbor/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  final Cart _cart = Cart.instance;
  final ImagePicker _picker = ImagePicker();
  dynamic _selectedImage;
  String? _base64String;

  late StreamController<QuerySnapshot> _reviewsStreamController;
  late Stream<QuerySnapshot> _reviewsStream;

  late AnimationController _animationController;
  late AnimationController _heartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isExpanded = false;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  double _userRating = 0;
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';

  late String _productId;

  int _productStock = 0;
  bool _isLoadingStock = true;
  bool _stockNotificationShown = false;

  @override
  void initState() {
    super.initState();

    _productId =
        widget.product['id']?.toString() ??
        widget.product['_id']?.toString() ??
        widget.product['productId']?.toString() ??
        widget.product['name']?.toString() ??
        'unknown_product';

    _reviewsStreamController = StreamController<QuerySnapshot>.broadcast();
    _reviewsStream = _reviewsStreamController.stream;
    _fetchReviews();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();

    _checkLoginStatus();

    _fetchProductStock();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          _userName = user?.displayName ?? '';
          _userEmail = user?.email ?? '';

          if (_isLoggedIn && _userName.isNotEmpty) {
            _nameController.text = _userName;
          }
        });
      }
    });
  }

  Future<void> _fetchProductStock() async {
    try {
      DocumentSnapshot productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(_productId)
          .get();

      if (productDoc.exists) {
        setState(() {
          _productStock = int.tryParse(productDoc['stock'].toString()) ?? 0;
          _isLoadingStock = false;
        });

        _showStockNotification();
      } else {
        setState(() {
          _productStock = 0;
          _isLoadingStock = false;
        });

        _showStockNotification();
      }
    } catch (e) {
      print("Error fetching product stock: $e");
      setState(() {
        _productStock = 0;
        _isLoadingStock = false;
      });

      _showStockNotification();
    }
  }

  void _showStockNotification() {
    if (_stockNotificationShown || _isLoadingStock) return;

    setState(() {
      _stockNotificationShown = true;
    });

    String message;
    Color backgroundColor;

    if (_productStock <= 0) {
      message = 'This product is currently out of stock';
      backgroundColor = Colors.red;
    } else if (_productStock <= 2) {
      message = 'Only $_productStock left in stock';
      backgroundColor = Colors.orange;
    } else {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _productStock <= 0
                  ? Icons.error_outline
                  : Icons.warning_amber_outlined,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _fetchReviews() {
    print('Fetching reviews for product ID: $_productId');
    print('Product name: ${widget.product['name']}');

    FirebaseFirestore.instance.collection('reviews').get().then((allReviews) {
      print('Total reviews in collection: ${allReviews.docs.length}');
      for (var doc in allReviews.docs) {
        print('Review doc ID: ${doc.id}, productId: ${doc['productId']}');
      }
    });

    FirebaseFirestore.instance
        .collection('reviews')
        .where('productId', isEqualTo: _productId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          print(
            'Found ${snapshot.docs.length} reviews for product ID: $_productId',
          );
          if (_reviewsStreamController.hasListener &&
              !_reviewsStreamController.isClosed) {
            _reviewsStreamController.add(snapshot);
          }
        });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartAnimationController.dispose();
    _reviewController.dispose();
    _nameController.dispose();
    _reviewsStreamController.close();
    super.dispose();
  }

  void _checkLoginStatus() {
    final User? user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoggedIn = user != null;
      _userName = user?.displayName ?? '';
      _userEmail = user?.email ?? '';

      if (_isLoggedIn && _userName.isNotEmpty) {
        _nameController.text = _userName;
      }
    });
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
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
        _base64String = base64String;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
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
        _base64String = base64String;
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _addToCart() {
    if (_productStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is currently out of stock'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_quantity > _productStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only $_productStock units available in stock'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final product = widget.product;
    final productId = product['id'] ?? product['name'];

    final item = {
      'id': productId,
      'name': product['name'] ?? 'Unnamed Product',
      'brand': product['brand'] ?? 'Unknown',
      'price': double.tryParse(product['price'].toString()) ?? 0.0,
      'quantity': _quantity,
      'imageUrl': product['imageUrl'] ?? product['image'] ?? '',
    };

    bool itemExists = false;
    final cartItems = _cart.items;

    if (cartItems.containsKey(productId)) {
      final existingItem = cartItems[productId]!;
      final currentQuantity = existingItem['quantity'] ?? 1;
      _cart.updateQuantity(productId, currentQuantity + _quantity);
      itemExists = true;
    } else {
      _cart.addItem(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 10,
        backgroundColor: AppColors.main,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),

        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width < 600
              ? 16
              : MediaQuery.of(context).size.width < 1024
              ? MediaQuery.of(context).size.width * 0.2
              : MediaQuery.of(context).size.width * 0.3,
          vertical: 20,
        ),

        content: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            bool isMobile = screenWidth < 600;
            bool isTablet = screenWidth >= 600 && screenWidth < 1024;
            bool isDesktop = screenWidth >= 1024;

            double fontSize = isDesktop
                ? 18
                : isTablet
                ? 16
                : 14;
            double iconSize = isDesktop
                ? 26
                : isTablet
                ? 22
                : 20;
            double spacing = isDesktop
                ? 12
                : isTablet
                ? 10
                : 8;

            return Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: iconSize),
                SizedBox(width: spacing),
                Expanded(
                  child: Text(
                    itemExists
                        ? "Cart updated: ${_quantity} more ${product['name']}"
                        : "${_quantity} x ${product['name']} added to cart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        ),

        duration: const Duration(seconds: 2),

        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );

    setState(() {
      _quantity = 1;
    });
  }

  void _buyNow() {
    if (_productStock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is currently out of stock'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_quantity > _productStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Only $_productStock units available in stock'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final product = widget.product;
    final productId = product['id'] ?? product['name'];

    final item = {
      'id': productId,
      'name': product['name'] ?? 'Unnamed Product',
      'brand': product['brand'] ?? 'Unknown',
      'price': double.tryParse(product['price'].toString()) ?? 0.0,
      'quantity': _quantity,
      'imageUrl': product['imageUrl'] ?? product['image'] ?? '',
    };

    bool itemExists = false;
    final cartItems = _cart.items;

    if (cartItems.containsKey(productId)) {
      final existingItem = cartItems[productId]!;
      final currentQuantity = existingItem['quantity'] ?? 1;
      _cart.updateQuantity(productId, currentQuantity + _quantity);
      itemExists = true;
    } else {
      _cart.addItem(item);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );

    setState(() {
      _quantity = 1;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    if (_isFavorite) {
      _heartAnimationController.forward().then((_) {
        _heartAnimationController.reverse();
      });
    }
  }

  void _submitReview() async {
    if (_reviewController.text.isNotEmpty && _userRating > 0) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      Map<String, dynamic> newReview = {
        'productId': _productId,
        'productName': widget.product['name'] ?? 'Unknown Product',
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'userName': _userName.isNotEmpty ? _userName : _userEmail.split('@')[0],
        'userEmail': _userEmail,
        'rating': _userRating,
        'comment': _reviewController.text,
        'timestamp': FieldValue.serverTimestamp(),
      };

      if (_base64String != null) {
        newReview['imageBase64'] = _base64String;
      }

      print('Submitting review for product ID: $_productId');
      print('Product name: ${widget.product['name']}');

      try {
        await FirebaseFirestore.instance.collection('reviews').add(newReview);

        _reviewController.clear();
        _userRating = 0;
        setState(() {
          _selectedImage = null;
          _base64String = null;
        });

        Navigator.of(context).pop();
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your review!'),
            backgroundColor: Colors.green,
          ),
        );

        _fetchReviews();
      } catch (e) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a rating and review text'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAddReviewDialog() {
    if (!_isLoggedIn) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to login to add a review.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.main),
              child: const Text('Login'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Your Review'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.main),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reviewing as: ${_userName.isNotEmpty ? _userName : _userEmail.split('@')[0]}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Rating:'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < _userRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          _userRating = index + 1.0;
                        });
                        setDialogState(() {});
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),

                if (_selectedImage != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: _selectedImage.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.data != null) {
                                    return Image.memory(
                                      snapshot.data!,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const CircularProgressIndicator();
                                },
                              )
                            : Image.file(
                                _selectedImage,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedImage = null;
                            _base64String = null;
                          });
                          setDialogState(() {});
                        },
                        child: const Text(
                          'Remove Image',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(
                        onPressed: () async {
                          await _pickImageFromCamera();
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Camera'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await _pickImageFromGallery();
                          setDialogState(() {});
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                TextField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Your Review',
                    hintText: 'Share your experience...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  style: const TextStyle(color: Colors.black),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                  _base64String = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _submitReview,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.main),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final isSmallScreen = screenWidth < 400;
    final isRegularPhone = screenWidth >= 400 && screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;
    final isDesktop = screenWidth >= 1000;

    final horizontalPadding = isDesktop
        ? screenWidth * 0.15
        : isTablet
        ? screenWidth * 0.1
        : isSmallScreen
        ? 12.0
        : 16.0;

    final titleFontSize = isDesktop
        ? 32.0
        : isTablet
        ? 28.0
        : isSmallScreen
        ? 22.0
        : 24.0;
    final subtitleFontSize = isDesktop
        ? 20.0
        : isTablet
        ? 18.0
        : isSmallScreen
        ? 14.0
        : 16.0;
    final bodyFontSize = isDesktop
        ? 18.0
        : isTablet
        ? 16.0
        : isSmallScreen
        ? 14.0
        : 15.0;
    final priceFontSize = isDesktop
        ? 32.0
        : isTablet
        ? 28.0
        : isSmallScreen
        ? 22.0
        : 24.0;
    final imageHeight = isDesktop
        ? screenHeight * 0.4
        : isTablet
        ? screenHeight * 0.35
        : screenHeight * 0.4;
    final buttonHeight = isDesktop
        ? 56.0
        : isTablet
        ? 50.0
        : isSmallScreen
        ? 40.0
        : 45.0;
    final cardPadding = isDesktop
        ? 28.0
        : isTablet
        ? 24.0
        : isSmallScreen
        ? 16.0
        : 20.0;
    final bottomPadding = isDesktop
        ? 120.0
        : isTablet
        ? 100.0
        : isSmallScreen
        ? 80.0
        : 90.0;

    // NEW: Check if buttons should be disabled
    final isOutOfStock = _productStock <= 0;
    final isQuantityExceedsStock = _quantity > _productStock;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.black,
              ),
              onPressed: _toggleFavorite,
            ),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.main,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${_cart.items.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'product-${widget.product['id']}',
                      child: Container(
                        height: imageHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                          child:
                              widget.product['imageUrl'] != null ||
                                  widget.product['image'] != null
                              ? Image.network(
                                  widget.product['imageUrl'] ??
                                      widget.product['image'],
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[100],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: isDesktop
                                            ? 100
                                            : isTablet
                                            ? 90
                                            : 80,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.image_not_supported,
                                    size: isDesktop
                                        ? 100
                                        : isTablet
                                        ? 90
                                        : 80,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: isDesktop ? 30.0 : 20.0),
                    // =========== Product Details Section ===========
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.product['name'] ??
                                          'Unnamed Product',
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        color: AppColors.dark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4.0 : 5.0),
                                    Text(
                                      widget.product['brand'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: _reviewsStream,
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return _buildRatingWidget(0.0, 0);
                                  }
                                  final reviews = snapshot.data!.docs;
                                  double totalRating = 0.0;
                                  for (var doc in reviews) {
                                    totalRating +=
                                        (doc.data()
                                            as Map<
                                              String,
                                              dynamic
                                            >)['rating'] ??
                                        0.0;
                                  }
                                  final avgRating = reviews.isEmpty
                                      ? 0.0
                                      : totalRating / reviews.length;
                                  return _buildRatingWidget(
                                    avgRating,
                                    reviews.length,
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: isDesktop ? 20.0 : 15.0),
                          Text(
                            "Rs. ${widget.product['price']}",
                            style: TextStyle(
                              fontSize: priceFontSize,
                              color: AppColors.main,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 20.0 : 15.0),
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: titleFontSize - 4,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isDesktop ? 10.0 : 8.0),
                          Text(
                            widget.product['description'] ??
                                'No description available for this product.',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 25.0 : 20.0),
                    // ========= Quantity Section =========
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Quantity:",
                            style: TextStyle(
                              fontSize: isDesktop
                                  ? 20
                                  : isTablet
                                  ? 18
                                  : 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    size: isDesktop ? 24 : 20,
                                  ),
                                  onPressed: () {
                                    if (_quantity > 1)
                                      setState(() {
                                        _quantity--;
                                      });
                                  },
                                ),
                                Container(
                                  width: isDesktop ? 50 : 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "$_quantity",
                                    style: TextStyle(
                                      fontSize: isDesktop
                                          ? 20
                                          : isTablet
                                          ? 18
                                          : 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: isDesktop ? 24 : 20,
                                  ),
                                  onPressed: () {
                                    // NEW: Don't allow increasing quantity beyond stock
                                    if (_quantity < _productStock) {
                                      setState(() {
                                        _quantity++;
                                      });
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Maximum available quantity: $_productStock',
                                          ),
                                          backgroundColor: Colors.orange,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ========= Quantity Section End =========
                    SizedBox(height: isDesktop ? 25.0 : 20.0),

                    // ========= Reviews Section =========
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Customer Reviews",
                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? 22
                                      : isTablet
                                      ? 20
                                      : 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              _isLoggedIn
                                  ? TextButton(
                                      onPressed: _showAddReviewDialog,
                                      child: Text(
                                        "Add Review",
                                        style: TextStyle(
                                          color: AppColors.main,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isDesktop ? 16 : 14,
                                        ),
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Login Required'),
                                            content: const Text(
                                              'You need to login to add a review.',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const LoginScreen(),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.main,
                                                ),
                                                child: const Text('Login'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.login,
                                        size: isDesktop ? 16 : 14,
                                        color: Colors.grey[600],
                                      ),
                                      label: Text(
                                        "Login to Review",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                          fontSize: isDesktop ? 16 : 14,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                          SizedBox(height: isDesktop ? 15.0 : 10.0),
                          StreamBuilder<QuerySnapshot>(
                            stream: _reviewsStream,
                            builder: (context, snapshot) {
                              print(
                                'StreamBuilder state: ${snapshot.connectionState}',
                              );
                              if (snapshot.hasError) {
                                print('StreamBuilder error: ${snapshot.error}');
                                return Text('Error: ${snapshot.error}');
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                print(
                                  'No reviews found for product ID: $_productId',
                                );
                                return const Text(
                                  'No reviews yet. Be the first to review!',
                                );
                              }

                              print(
                                'Found ${snapshot.data!.docs.length} reviews in StreamBuilder',
                              );

                              final reviews = snapshot.data!.docs;
                              double totalRating = 0.0;
                              for (var doc in reviews) {
                                totalRating +=
                                    (doc.data()
                                        as Map<String, dynamic>)['rating'] ??
                                    0.0;
                              }
                              final averageRating = reviews.isEmpty
                                  ? 0.0
                                  : totalRating / reviews.length;
                              final totalReviews = reviews.length;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        averageRating.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontSize: isDesktop
                                              ? 40
                                              : isTablet
                                              ? 36
                                              : 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: isDesktop ? 12 : 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: List.generate(5, (index) {
                                              return Icon(
                                                index < averageRating.floor()
                                                    ? Icons.star
                                                    : index < averageRating
                                                    ? Icons.star_half
                                                    : Icons.star_border,
                                                color: Colors.amber,
                                                size: isDesktop
                                                    ? 28
                                                    : isTablet
                                                    ? 24
                                                    : 20,
                                              );
                                            }),
                                          ),
                                          Text(
                                            "$totalReviews reviews",
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: isDesktop
                                                  ? 18
                                                  : isTablet
                                                  ? 16
                                                  : 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: isDesktop ? 25.0 : 20.0),

                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: reviews.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final reviewData =
                                          reviews[index].data()
                                              as Map<String, dynamic>;
                                      final timestamp =
                                          reviewData['timestamp'] as Timestamp?;
                                      final date = timestamp != null
                                          ? _formatDate(timestamp.toDate())
                                          : 'Unknown date';

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: isDesktop ? 12.0 : 8.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  reviewData['userName'] ??
                                                      'Anonymous',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isDesktop
                                                        ? 18
                                                        : isTablet
                                                        ? 16
                                                        : 14,
                                                    color: AppColors.dark,
                                                  ),
                                                ),
                                                Text(
                                                  date,
                                                  style: TextStyle(
                                                    color: AppColors.dark,
                                                    fontSize: isDesktop
                                                        ? 16
                                                        : isTablet
                                                        ? 14
                                                        : 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: isDesktop ? 6.0 : 4.0,
                                            ),
                                            Row(
                                              children: List.generate(5, (
                                                index,
                                              ) {
                                                return Icon(
                                                  index < reviewData['rating']
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: Colors.amber,
                                                  size: isDesktop
                                                      ? 22
                                                      : isTablet
                                                      ? 18
                                                      : 16,
                                                );
                                              }),
                                            ),
                                            SizedBox(
                                              height: isDesktop ? 12.0 : 8.0,
                                            ),

                                            if (reviewData['imageBase64'] !=
                                                null)
                                              Container(
                                                margin: EdgeInsets.only(
                                                  bottom: isDesktop
                                                      ? 12.0
                                                      : 8.0,
                                                ),
                                                height: 150,
                                                width: double.infinity,
                                                child: Image.memory(
                                                  base64Decode(
                                                    reviewData['imageBase64'],
                                                  ),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => const Icon(
                                                        Icons.broken_image,
                                                      ),
                                                ),
                                              ),

                                            Text(
                                              reviewData['comment'] ?? '',
                                              style: TextStyle(
                                                fontSize: isDesktop
                                                    ? 18
                                                    : isTablet
                                                    ? 16
                                                    : 14,
                                                color: AppColors.dark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ), // ========= Reviews Section End =========
                    SizedBox(height: isDesktop ? 30.0 : 20.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                bool isMobile = screenWidth < 600;
                bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                bool isDesktop = screenWidth >= 1024;

                double buttonHeight = isDesktop
                    ? 56
                    : isTablet
                    ? 50
                    : 46;
                double spacing = isDesktop
                    ? 24
                    : isTablet
                    ? 18
                    : 14;
                double fontSize = isDesktop
                    ? 16
                    : isTablet
                    ? 14
                    : 12;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop
                        ? screenWidth * 0.1
                        : isTablet
                        ? screenWidth * 0.06
                        : screenWidth * 0.05,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      // ======== Add to Cart Button ========
                      Expanded(
                        child: SizedBox(
                          height: buttonHeight,
                          child: OutlinedButton.icon(
                            onPressed: isOutOfStock ? null : _addToCart,
                            icon: Icon(
                              Icons.shopping_cart_outlined,
                              color: isOutOfStock
                                  ? Colors.grey
                                  : AppColors.main,
                              size: fontSize + 4,
                            ),
                            label: Text(
                              "Add to Cart",
                              style: TextStyle(
                                color: isOutOfStock
                                    ? Colors.grey
                                    : AppColors.main,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isOutOfStock
                                    ? Colors.grey
                                    : AppColors.main,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              backgroundColor: Colors.white,
                              foregroundColor: isOutOfStock
                                  ? Colors.grey
                                  : AppColors.main,
                              overlayColor: isOutOfStock
                                  ? null
                                  : AppColors.main.withOpacity(0.1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),

                      // ======== Buy Now Button ========
                      Expanded(
                        child: SizedBox(
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: isOutOfStock ? null : _buyNow,
                            style:
                                ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  backgroundColor: isOutOfStock
                                      ? Colors.grey
                                      : AppColors.main,
                                  shadowColor: isOutOfStock
                                      ? null
                                      : AppColors.main.withOpacity(0.3),
                                  elevation: isOutOfStock ? 0 : 5,
                                ).copyWith(
                                  backgroundColor:
                                      WidgetStateProperty.resolveWith((states) {
                                        if (states.contains(
                                          WidgetState.pressed,
                                        )) {
                                          return isOutOfStock
                                              ? Colors.grey
                                              : AppColors.main.withOpacity(0.8);
                                        }
                                        return isOutOfStock
                                            ? Colors.grey
                                            : AppColors.main;
                                      }),
                                ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: fontSize + 4,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "BUY NOW",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSize + 1,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingWidget(double rating, int count) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1000;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.main.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: Colors.amber[600], size: isDesktop ? 22 : 18),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isDesktop ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
