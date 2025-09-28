import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const LaptopHarborApp()); // 👈 class rename
}

class LaptopHarborApp extends StatelessWidget {
  const LaptopHarborApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Laptop Harbor", // 👈 new app name
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ✅ sabse pehle SplashScreen chalegi
      home: const SplashScreen(),
    );
  }
}
