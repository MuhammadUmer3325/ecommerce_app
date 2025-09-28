import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    // ===================== COLORS =====================
    primaryColor: AppColors.main,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: false, // Material 2 styling (zyada stable)
    // ===================== APP BAR THEME =====================
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.dark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.dark, size: 22),
    ),

    // ===================== TEXT THEME =====================
    textTheme: TextTheme(
      // Headings
      headlineLarge: GoogleFonts.poppins(
        color: AppColors.dark,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: GoogleFonts.montserrat(
        color: AppColors.dark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: GoogleFonts.poppins(
        color: AppColors.dark,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),

      // Body
      bodyLarge: GoogleFonts.roboto(color: AppColors.dark, fontSize: 16),
      bodyMedium: GoogleFonts.roboto(color: AppColors.hint, fontSize: 14),
      bodySmall: GoogleFonts.roboto(color: AppColors.hint, fontSize: 12),
    ),

    // ===================== ELEVATED BUTTON THEME =====================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark,
        foregroundColor: AppColors.light,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 6,
        shadowColor: Colors.black38,
        textStyle: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    // // ===================== ADD TO CART BUTTON THEME =====================
    // textButtonTheme: TextButtonThemeData(
    //   style: TextButton.styleFrom(
    //     backgroundColor: AppColors.main, // ✅ Primary theme color
    //     foregroundColor: AppColors.light, // ✅ White text
    //     padding: const EdgeInsets.symmetric(
    //       horizontal: 20,
    //       vertical: 12,
    //     ), // ✅ Compact size
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    //     elevation: 4,
    //     shadowColor: Colors.black26,
    //     textStyle: GoogleFonts.montserrat(
    //       fontSize: 14, // ✅ Smaller font
    //       fontWeight: FontWeight.w600,
    //     ),
    //   ),
    // ),

    // ===================== INPUT FIELD THEME =====================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.dark,
      hintStyle: TextStyle(color: Colors.white70),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: BorderSide.none,
      ),
      prefixIconColor: AppColors.light,
    ),

    // ===================== ADDITIONAL COLORS =====================
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.main),
  );

  // ✅ Add to Cart button style (product card ke liye)
  static ButtonStyle cartButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.dark,
    foregroundColor: AppColors.light,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    textStyle: GoogleFonts.montserrat(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    elevation: 4,
    shadowColor: Colors.black26,
  );
}
