import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'package:laptop_harbor/screens/auth/login_screen.dart';
import 'package:laptop_harbor/screens/cart_screen.dart';
import 'package:laptop_harbor/screens/checkout_screen.dart';
import 'package:laptop_harbor/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this import

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  final Cart _cart = Cart.instance;
  late AnimationController _animationController;
  late AnimationController _heartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isExpanded = false;
  double _averageRating = 4.5;
  int _totalReviews = 128;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  double _userRating = 0;
  bool _isLoggedIn = false; // Track if user is logged in
  String _userName = ''; // Store user name if logged in
  String _userEmail = ''; // Store user email if logged in

  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Ahmed Ali',
      'rating': 5.0,
      'date': '2 days ago',
      'comment': 'Excellent laptop! Very fast and the display is amazing.',
    },
    {
      'name': 'Sara Khan',
      'rating': 4.0,
      'date': '1 week ago',
      'comment': 'Good value for money. Battery life could be better.',
    },
    {
      'name': 'Usman Malik',
      'rating': 4.5,
      'date': '2 weeks ago',
      'comment': 'Great performance for gaming and work.',
    },
  ];

  @override
  void initState() {
    super.initState();
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

    // Check if user is logged in
    _checkLoginStatus();

    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _isLoggedIn = user != null;
          _userName = user?.displayName ?? '';
          _userEmail = user?.email ?? '';

          // If user is logged in, pre-fill the name field
          if (_isLoggedIn && _userName.isNotEmpty) {
            _nameController.text = _userName;
          }
        });
      }
    });
  }

  void _checkLoginStatus() {
    // Check if user is logged in using Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;

    setState(() {
      _isLoggedIn = user != null;
      _userName = user?.displayName ?? '';
      _userEmail = user?.email ?? '';

      // If user is logged in, pre-fill the name field
      if (_isLoggedIn && _userName.isNotEmpty) {
        _nameController.text = _userName;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _heartAnimationController.dispose();
    _reviewController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final product = widget.product;
    final productId = product['id'] ?? product['name'];

    // Create the item to add
    final item = {
      'id': productId,
      'name': product['name'] ?? 'Unnamed Product',
      'brand': product['brand'] ?? 'Unknown',
      'price': double.tryParse(product['price'].toString()) ?? 0.0,
      'quantity': _quantity,
      'imageUrl': product['imageUrl'] ?? product['image'] ?? '',
    };

    // Check if product already exists in cart
    bool itemExists = false;
    final cartItems =
        _cart.items; // Using _cart.items directly as per CartScreen

    // Check if the item already exists in the cart
    if (cartItems.containsKey(productId)) {
      // Product exists, update quantity
      final existingItem = cartItems[productId]!;
      final currentQuantity = existingItem['quantity'] ?? 1;
      _cart.updateQuantity(productId, currentQuantity + _quantity);
      itemExists = true;
    } else {
      // Product doesn't exist, add new item
      _cart.addItem(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              itemExists
                  ? "Cart updated: ${_quantity} more ${product['name']}"
                  : "${_quantity} x ${product['name']} added to cart",
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.main,
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

    // Reset quantity after adding to cart
    setState(() {
      _quantity = 1;
    });
  }

  void _buyNow() {
    final product = widget.product;
    final productId = product['id'] ?? product['name'];

    // Create the item to add
    final item = {
      'id': productId,
      'name': product['name'] ?? 'Unnamed Product',
      'brand': product['brand'] ?? 'Unknown',
      'price': double.tryParse(product['price'].toString()) ?? 0.0,
      'quantity': _quantity,
      'imageUrl': product['imageUrl'] ?? product['image'] ?? '',
    };

    // Check if product already exists in cart
    bool itemExists = false;
    final cartItems =
        _cart.items; // Using _cart.items directly as per CartScreen

    // Check if the item already exists in the cart
    if (cartItems.containsKey(productId)) {
      // Product exists, update quantity
      final existingItem = cartItems[productId]!;
      final currentQuantity = existingItem['quantity'] ?? 1;
      _cart.updateQuantity(productId, currentQuantity + _quantity);
      itemExists = true;
    } else {
      // Product doesn't exist, add new item
      _cart.addItem(item);
    }

    // Navigate to checkout screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
    );

    // Reset quantity after buying
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

  void _submitReview() {
    if (_reviewController.text.isNotEmpty && _userRating > 0) {
      setState(() {
        _reviews.insert(0, {
          'name': _isLoggedIn
              ? (_userName.isNotEmpty ? _userName : _userEmail.split('@')[0])
              : _nameController.text,
          'rating': _userRating,
          'date': 'Just now',
          'comment': _reviewController.text,
        });
        // Update average rating
        double totalRating = _reviews.fold(
          0.0,
          (sum, review) => sum + review['rating'],
        );
        _averageRating = totalRating / _reviews.length;
        _totalReviews = _reviews.length;
      });
      _reviewController.clear();
      _userRating = 0;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you for your review!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showAddReviewDialog() {
    if (!_isLoggedIn) {
      // Show login prompt if user is not logged in
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

    // Show review dialog if user is logged in
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Your Review'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show user's info if logged in
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
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    labelText: 'Your Review',
                    hintText: 'Share your experience with this product...',
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.main,
                        width: 1.5,
                      ),
                    ),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _submitReview,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.main),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive design variables
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define breakpoints for different screen sizes
    final isSmallScreen = screenWidth < 400; // Small phones
    final isRegularPhone =
        screenWidth >= 400 && screenWidth < 600; // Regular phones
    final isTablet = screenWidth >= 600 && screenWidth < 1000; // Tablets
    final isDesktop = screenWidth >= 1000; // Desktop/Web

    // Calculate responsive padding and margins
    final horizontalPadding = isDesktop
        ? screenWidth * 0.15
        : isTablet
        ? screenWidth * 0.1
        : isSmallScreen
        ? 12.0
        : 16.0;

    // Calculate responsive font sizes
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

    // Calculate responsive image height
    final imageHeight = isDesktop
        ? screenHeight * 0.4
        : isTablet
        ? screenHeight * 0.35
        : screenHeight * 0.4;

    // Calculate responsive button height
    final buttonHeight = isDesktop
        ? 56.0
        : isTablet
        ? 50.0
        : isSmallScreen
        ? 40.0
        : 45.0;

    // Calculate responsive card padding
    final cardPadding = isDesktop
        ? 28.0
        : isTablet
        ? 24.0
        : isSmallScreen
        ? 16.0
        : 20.0;

    // Calculate responsive bottom padding for scrollable content
    final bottomPadding = isDesktop
        ? 120.0
        : isTablet
        ? 100.0
        : isSmallScreen
        ? 80.0
        : 90.0;

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
                  // Fixed cart navigation
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
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                // Add padding at bottom to prevent content being hidden behind fixed buttons
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image with Hero Animation
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

                    // Product Info Card
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
                          // Product Name and Brand
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
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 4.0 : 5.0),
                                    Text(
                                      widget.product['brand'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: subtitleFontSize,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.main.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[600],
                                      size: isDesktop ? 22 : 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _averageRating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isDesktop ? 16 : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: isDesktop ? 20.0 : 15.0),

                          // Price
                          Row(
                            children: [
                              Text(
                                "Rs. ${widget.product['price']}",
                                style: TextStyle(
                                  fontSize: priceFontSize,
                                  color: AppColors.main,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 10),
                              if (widget.product['originalPrice'] != null)
                                Text(
                                  "Rs. ${widget.product['originalPrice']}",
                                  style: TextStyle(
                                    fontSize: isDesktop
                                        ? 24
                                        : isTablet
                                        ? 20
                                        : 18,
                                    color: Colors.grey[500],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              if (widget.product['discount'] != null)
                                Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${widget.product['discount']}% OFF",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 14 : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: isDesktop ? 25.0 : 20.0),

                          // Description
                          Text(
                            "Description",
                            style: TextStyle(
                              fontSize: isDesktop
                                  ? 22
                                  : isTablet
                                  ? 20
                                  : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6.0 : 8.0),
                          Text(
                            widget.product['description'] ??
                                'No description available',
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                            maxLines: _isExpanded ? null : 3,
                            overflow: _isExpanded
                                ? null
                                : TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isSmallScreen ? 6.0 : 8.0),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isExpanded = !_isExpanded;
                              });
                            },
                            child: Text(
                              _isExpanded ? 'Read less' : 'Read more',
                              style: TextStyle(
                                color: AppColors.main,
                                fontWeight: FontWeight.bold,
                                fontSize: isDesktop ? 16 : 14,
                              ),
                            ),
                          ),

                          SizedBox(height: isDesktop ? 25.0 : 20.0),

                          // Specifications
                          if (widget.product['specifications'] != null) ...[
                            Text(
                              "Specifications",
                              style: TextStyle(
                                fontSize: isDesktop
                                    ? 22
                                    : isTablet
                                    ? 20
                                    : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isDesktop ? 15.0 : 10.0),
                            _buildSpecifications(
                              widget.product['specifications'],
                              isDesktop,
                              isTablet,
                              isSmallScreen,
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: isDesktop ? 25.0 : 20.0),

                    // Quantity Selector
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
                                    if (_quantity > 1) {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
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
                                    setState(() {
                                      _quantity++;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isDesktop ? 25.0 : 20.0),

                    // Reviews Section
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
                                ),
                              ),
                              TextButton(
                                onPressed: _showAddReviewDialog,
                                child: Text(
                                  "Add Review",
                                  style: TextStyle(
                                    color: AppColors.main,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isDesktop ? 16 : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: isDesktop ? 15.0 : 10.0),
                          Row(
                            children: [
                              Text(
                                _averageRating.toStringAsFixed(1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < _averageRating.floor()
                                            ? Icons.star
                                            : index < _averageRating
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
                                    "$_totalReviews reviews",
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
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length > 3
                                ? 3
                                : _reviews.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final review = _reviews[index];
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: isDesktop ? 12.0 : 8.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          review['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isDesktop
                                                ? 18
                                                : isTablet
                                                ? 16
                                                : 14,
                                          ),
                                        ),
                                        Text(
                                          review['date'],
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: isDesktop
                                                ? 16
                                                : isTablet
                                                ? 14
                                                : 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isDesktop ? 6.0 : 4.0),
                                    Row(
                                      children: List.generate(5, (index) {
                                        return Icon(
                                          index < review['rating']
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
                                    SizedBox(height: isDesktop ? 12.0 : 8.0),
                                    Text(
                                      review['comment'],
                                      style: TextStyle(
                                        fontSize: isDesktop
                                            ? 18
                                            : isTablet
                                            ? 16
                                            : 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (_reviews.length > 3)
                            TextButton(
                              onPressed: () {
                                // Navigate to all reviews screen
                              },
                              child: Text(
                                "View all reviews",
                                style: TextStyle(
                                  color: AppColors.main,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 16 : 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Add extra space at bottom to ensure content doesn't get hidden behind fixed buttons
                    SizedBox(height: isDesktop ? 30.0 : 20.0),
                  ],
                ),
              ),
            ),
          ),

          // 🔥 Fully Responsive Fixed Buttons at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double screenHeight = MediaQuery.of(context).size.height;

                // Define breakpoints
                bool isMobile = screenWidth < 600;
                bool isTablet = screenWidth >= 600 && screenWidth < 1024;
                bool isDesktop = screenWidth >= 1024;

                // Dynamic padding and sizes
                double horizontalPadding = isDesktop
                    ? screenWidth * 0.1
                    : isTablet
                    ? screenWidth * 0.06
                    : screenWidth * 0.05;

                double buttonHeight = isDesktop
                    ? 56
                    : isTablet
                    ? 50
                    : 45;

                double iconSize = isDesktop
                    ? 24
                    : isTablet
                    ? 22
                    : 20;

                double fontSize = isDesktop
                    ? 16
                    : isTablet
                    ? 14
                    : 12;

                double spacing = isDesktop
                    ? 24
                    : isTablet
                    ? 20
                    : 14;

                return Container(
                  padding: EdgeInsets.all(
                    isDesktop
                        ? 20
                        : isTablet
                        ? 16
                        : 12,
                  ),
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 🛒 Add to Cart Button
                            Expanded(
                              child: Container(
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: AppColors.main),
                                ),
                                child: OutlinedButton.icon(
                                  onPressed: _addToCart,
                                  icon: Icon(
                                    Icons.shopping_cart_outlined,
                                    size: iconSize,
                                    color: AppColors.main,
                                  ),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "ADD TO CART",
                                      style: TextStyle(
                                        color: AppColors.main,
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: isMobile ? 8 : 16,
                                    ),
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: spacing),

                            // ⚡ Buy Now Button
                            Expanded(
                              child: Container(
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  color: AppColors.main,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.main.withOpacity(0.3),
                                      spreadRadius: 0,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _buyNow,
                                  icon: Icon(Icons.flash_on, size: iconSize),
                                  label: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "BUY NOW",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSize,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecifications(
    Map<String, dynamic> specs,
    bool isDesktop,
    bool isTablet,
    bool isSmallScreen,
  ) {
    return Column(
      children: specs.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: isDesktop ? 8.0 : 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isDesktop
                    ? 160
                    : isTablet
                    ? 140
                    : 120,
                child: Text(
                  "${entry.key}:",
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 18
                        : isTablet
                        ? 16
                        : 15,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value.toString(),
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 18
                        : isTablet
                        ? 16
                        : 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
