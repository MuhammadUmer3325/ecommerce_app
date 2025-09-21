import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // ===================== COLORS =====================
    primaryColor: AppColors.lightBlue1,
    scaffoldBackgroundColor: AppColors.lightBlue2,
    fontFamily: AppFonts.primaryFont,

    // ===================== APP BAR THEME =====================
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBlue1,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // ===================== TEXT THEME =====================
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: AppColors.lightPurple1,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightPurple2,
        fontSize: 14,
      ),
    ),

    // ===================== ELEVATED BUTTON THEME =====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightBlue1,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // ===================== ADDITIONAL COLORS =====================
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: AppColors.lightPink, // floating buttons, sliders, switches
    ),
  );
}
