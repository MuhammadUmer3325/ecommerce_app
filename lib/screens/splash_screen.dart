// ===================== SPLASH SCREEN =====================
// lib/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // ===================== INIT STATE =====================
  @override
  void initState() {
    super.initState();

    // Redirect after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  // ===================== BUILD METHOD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF636B2F), // Primary color

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // --------------------- APP LOGO ---------------------
            Icon(
              Icons.shopping_bag,
              size: 80,
              color: Color(0xFFD4DE95), // Accent color
            ),

            SizedBox(height: 20),

            // --------------------- APP NAME ---------------------
            Text(
              "Ecommerce",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4DE95),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
