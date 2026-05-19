import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricYellow,
        secondary: AppColors.neonPink,
        tertiary: AppColors.neonCyan,
        surface: AppColors.bgCard,
        onPrimary: AppColors.bgDeep,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.bangers(
          fontSize: 56,
          color: AppColors.electricYellow,
          letterSpacing: 3,
        ),
        displayMedium: GoogleFonts.bangers(
          fontSize: 40,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        titleLarge: GoogleFonts.bangers(
          fontSize: 26,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        titleMedium: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.montserrat(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.montserrat(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.bangers(
          fontSize: 16,
          letterSpacing: 1,
          color: AppColors.bgDeep,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.bangers(
          fontSize: 30,
          color: AppColors.electricYellow,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: AppColors.electricYellow),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonPink,
        foregroundColor: AppColors.textPrimary,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.electricYellow, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.electricYellow, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.electricYellow.withOpacity(0.4), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.electricYellow, width: 2),
        ),
        labelStyle: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.montserrat(color: AppColors.textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.bgCard,
        contentTextStyle: GoogleFonts.montserrat(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.electricYellow, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
