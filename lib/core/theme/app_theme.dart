import 'package:ecommerce/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // ===================== COLORS =====================
    primaryColor: AppColors.main,
    scaffoldBackgroundColor: AppColors.bg,

    // ===================== APP BAR THEME =====================
    appBarTheme: AppBarTheme(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.dark,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: AppColors.light),
    ),

    // ===================== TEXT THEME =====================
    textTheme: TextTheme(
      // ✅ Heading
      headlineLarge: GoogleFonts.poppins(
        color: AppColors.light,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      // ✅ Subheading
      headlineMedium: GoogleFonts.montserrat(
        color: AppColors.light,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      // ✅ Body
      bodyMedium: GoogleFonts.roboto(color: AppColors.hint, fontSize: 14),
    ),

    // ===================== ELEVATED BUTTON THEME =====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.main,
        foregroundColor: AppColors.light,
        textStyle: GoogleFonts.poppins(fontWeight: FontWeight.normal),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),

    // ===================== ADDITIONAL COLORS =====================
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: AppColors.hint, // sliders, switches, FAB etc.
    ),
  );
}
