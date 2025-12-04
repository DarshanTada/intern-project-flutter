/// NHL-themed color scheme and styling
library;
import 'package:flutter/material.dart';

class NHLTheme {
  // NHL Brand Colors
  static const Color nhlBlue = Color(0xFF003E7E);
  static const Color nhlLightBlue = Color(0xFF0074CC);
  static const Color nhlRed = Color(0xFFC8102E);
  static const Color nhlGold = Color(0xFFFFB81C);
  static const Color nhlDark = Color(0xFF0A0A0A);
  static const Color nhlDarkGray = Color(0xFF1A1A1A);
  static const Color nhlGray = Color(0xFF2A2A2A);
  static const Color nhlLightGray = Color(0xFF3A3A3A);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: nhlLightBlue,
        secondary: nhlGold,
        surface: nhlDarkGray,
        background: nhlDark,
        error: nhlRed,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: nhlDark,
      appBarTheme: AppBarTheme(
        backgroundColor: nhlDarkGray,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: nhlDarkGray,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: nhlLightGray,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: 24,
      ),
    );
  }
}

