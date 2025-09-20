// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart'; // 👈 import karo

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Redirect after 3 seconds → OnboardingScreen
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF636B2F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.shopping_bag, size: 80, color: Color(0xFFD4DE95)),
            SizedBox(height: 20),
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
