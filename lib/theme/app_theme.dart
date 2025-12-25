import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2979FF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color cardShadow = Color(0x1A000000);
  static const Color textDark = Color(0xFF212529);
  static const Color textGrey = Color(0xFF6C757D);
  static const Color dangerRed = Color(0xFFE53935);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        background: backgroundLight,
      ),
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
        color: Colors.white,
      ),
      fontFamily: 'Roboto', // Defaulting to Roboto
    );
  }
}
