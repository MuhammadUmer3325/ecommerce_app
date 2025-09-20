import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart'; // 👈 same folder me home_screen.dart hai to direct import ho jayega

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF636B2F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // ===================== LOTTIE ANIMATION =====================
              Lottie.asset(
                "assets/animations/welcome.json", // 👈 yahan welcome.json use karo
                height: 200,
                repeat: true,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              const Text(
                "Welcome to Ecommerce",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Discover the latest products at the best prices. Your shopping journey starts here!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),

              const Spacer(),

              // Get Started Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4DE95),
                  foregroundColor: const Color(0xFF3D4127),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    
                  ),
                ),
                onPressed: () {
                  // 👉 HomeScreen pe navigate karega
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
