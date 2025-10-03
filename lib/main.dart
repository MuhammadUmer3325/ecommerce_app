import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LaptopHarborApp());
}

class LaptopHarborApp extends StatelessWidget {
  const LaptopHarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Laptop Harbor",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Sabse pehle SplashScreen chalegi
      home: const SplashScreen(),
    );
  }
}
