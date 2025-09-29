import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class ProductDetailsScreen extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productImage;
  final String productDescription;

  const ProductDetailsScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        title: Text(productName, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8), // thoda margin
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dark, // ✅ Background white
              border: Border.all(
                color: AppColors.hint, // ✅ Border gray
                width: 1,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================== PRODUCT IMAGE ==================
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.dark,
                // borderRadius: const BorderRadius.only(
                //   bottomLeft: Radius.circular(30),
                //   bottomRight: Radius.circular(30),
                // ),
                image: DecorationImage(
                  image: AssetImage(productImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================== TITLE + PRICE ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(
                        color: AppColors.dark,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    productPrice,
                    style: TextStyle(
                      color: AppColors.dark,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================== RATING ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  5,
                  (index) =>
                      const Icon(Icons.star, color: Colors.amber, size: 22),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================== DESCRIPTION ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                productDescription,
                style: TextStyle(
                  color: AppColors.dark,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ================== ACTION BUTTONS ==================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.dark),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        "Add to Cart",
                        style: TextStyle(
                          color: AppColors.dark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dark,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
