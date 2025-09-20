import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const EcommerceApp());
}

class EcommerceApp extends StatelessWidget {
  const EcommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ecommerce",
      debugShowCheckedModeBanner: false,

      // ===================== THEME =====================
      theme: AppTheme.lightTheme,

      // ===================== STARTING SCREEN =====================
      home: const SplashScreen(),

      // ===================== ROUTES =====================
      routes: {
      
      },
    );
  }
}
