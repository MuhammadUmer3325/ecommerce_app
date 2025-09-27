import 'dart:ui';
import 'package:ecommerce/core/constants/app_constants.dart';
import 'package:ecommerce/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ===================== HALF ROUND BACKGROUND SHAPE =====================
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(1000.0),
                topRight: Radius.circular(1000.0),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 20,
                  sigmaY: 20,
                ), // 👈 strong blur
                child: Container(
                  height: screenHeight * 0.4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25), // upar light glass
                        Colors.white.withOpacity(
                          0.05,
                        ), // neeche darker transparent
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(1000.0),
                      topRight: Radius.circular(1000.0),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(
                        0.3,
                      ), // 👈 subtle glass border
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), // depth ke liye
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),

                  // ===================== LOTTIE ANIMATION =====================
                  Lottie.asset(
                    "assets/animations/welcome.json",
                    height: 200,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  // ===================== TITLE =====================
                  Text(
                    "Welcome to Ecommerce",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold, // heading ke liye bold hi rakh
                      color: AppColors.main,
                      letterSpacing:
                          0.5, // thoda spacing headings ko aur clean banati hai
                      shadows: const [
                        Shadow(
                          offset: Offset(0, 1), // sirf neeche halka sa
                          blurRadius: 3, // halka blur, soft look
                          color: Colors.black26, // light grey shadow
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===================== SUBTITLE =====================
                  Text(
                    "Discover the latest products at the best prices. Your shopping journey starts here!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.main,
                      height: 1.4,
                    ),
                  ),

                  const Spacer(),

                  // ===================== GET STARTED BUTTON =====================
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dark,
                      foregroundColor: AppColors.light,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 22,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                      shadowColor: Colors.black38,
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
