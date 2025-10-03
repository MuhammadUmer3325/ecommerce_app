import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase initialize
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

      // App start hone par sabse pehle SplashScreen chalegi
      home: const SplashScreen(),
    );
  }
}
