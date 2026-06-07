import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bgPrimary = Color(0xFF0A0A0F);
  static const bgSecondary = Color(0xFF111118);
  static const bgCard = Color(0xFF16161F);
  static const bgCardHover = Color(0xFF1E1E2A);
  static const bgInput = Color(0xFF1A1A24);
  static const border = Color(0xFF2A2A3A);
  static const borderLight = Color(0xFF333345);
  static const accent = Color(0xFF6C63FF);
  static const accentHover = Color(0xFF7C74FF);
  static const accentGlow = Color(0x4D6C63FF);
  static const accent2 = Color(0xFFFF6584);
  static const accent3 = Color(0xFF43D9AD);
  static const accent4 = Color(0xFFFFB347);
  static const textPrimary = Color(0xFFF0F0FF);
  static const textSecondary = Color(0xFF9090B0);
  static const textMuted = Color(0xFF5A5A7A);
  static const success = Color(0xFF43D9AD);
  static const warning = Color(0xFFFFB347);
  static const danger = Color(0xFFFF6584);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.accent2,
          surface: AppColors.bgCard,
          error: AppColors.danger,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white.withOpacity(0.05),
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
        ), // CardThemeData
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgInput,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textMuted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle:
                GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.border),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.bgCard,
          contentTextStyle: const TextStyle(color: AppColors.textPrimary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
