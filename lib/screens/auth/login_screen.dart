import 'package:ecommerce/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

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
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        78,
        78,
        78,
      ), // ✅ Dark background
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ App Logo / Icon
                Icon(Icons.shopping_bag, size: 80, color: AppColors.dark),
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
                  style: TextStyle(color: AppColors.hint, fontSize: 14),
                ),

                const SizedBox(height: 40),

                // ✅ Email Field
                TextField(
                  controller: emailController,
                  style: TextStyle(color: AppColors.light),
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: AppColors.hint),
                    filled: true,
                    fillColor: AppColors.dark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: AppColors.hint,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ✅ Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: TextStyle(color: AppColors.light),
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: AppColors.hint),
                    filled: true,
                    fillColor: AppColors.dark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.hint),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigate to Forgot Password Screen
                    },
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(color: AppColors.light, fontSize: 14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.main,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
                      "Login",
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ✅ Sign Up Redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don’t have an account?",
                      style: TextStyle(color: AppColors.hint),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to Sign Up Screen
                      },
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
