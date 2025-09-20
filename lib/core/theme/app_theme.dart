import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.secondary,
    fontFamily: AppFonts.primaryFont,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.neutral,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.neutral,
        fontSize: 14,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
