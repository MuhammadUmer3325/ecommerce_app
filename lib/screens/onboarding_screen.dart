import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/constants/app_constants.dart';
import 'package:laptop_harbor/screens/auth/login_screen.dart';
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

          // ===================== MAIN CONTENT =====================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),

                  // ===================== LOTTIE ANIMATION =====================
                  Lottie.asset(
                    "assets/animations/welcome.json",
                    height: 200,
                    repeat: true,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 5),

                  // ===================== TITLE =====================
                  Text(
                    "Welcome to \n Laptop Harbor",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      letterSpacing: 1,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.main,
                      // shadows: const [
                      //   Shadow(
                      //     offset: Offset(0, 1),
                      //     blurRadius: 3,
                      //     color: Colors.black26,
                      //   ),
                      // ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ===================== SUBTITLE =====================
                  Text(
                    "Upgrade your tech game with the latest laptops and gadgets at unbeatable prices!",
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
                          builder: (context) => const HomeScreen(),
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
