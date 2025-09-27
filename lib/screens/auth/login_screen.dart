import 'package:ecommerce/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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

          // ===================== LOGIN CONTENT =====================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // 👆 Expanded se upar wala content center hoga
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ✅ App Logo / Icon
                        Icon(
                          Icons.shopping_bag,
                          size: 80,
                          color: AppColors.dark,
                        ),
                        const SizedBox(height: 20),

                        // ✅ Title
                        Text(
                          "Welcome Back!",
                          style: TextStyle(
                            color: AppColors.dark,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Login to continue shopping",
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 40),

                        // ✅ Email Field
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: AppColors.dark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 12,
                              ),
                              child: Icon(
                                Icons.email_outlined,
                                color: AppColors.light,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ Password Field
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: AppColors.dark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 12,
                              ),
                              child: Icon(
                                Icons.lock_outline,
                                color: AppColors.light,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color.fromARGB(255, 228, 49, 49),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===================== BUTTON + SIGN UP BOTTOM =====================
                  Column(
                    children: [
                      // ✅ Login Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                          );
                        },
                        child: const Text("Login"),
                      ),

                      const SizedBox(height: 10),

                      // ✅ Sign Up Redirect
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don’t have an account?",
                            style: TextStyle(color: AppColors.dark),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                color: AppColors.dark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 70,
                      ), // 👈 yeh neeche thoda aur space dega
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
