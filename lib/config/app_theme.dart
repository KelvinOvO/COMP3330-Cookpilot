// lib/config/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: const Color(0xFF007AFF),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF2C2C2C)),
        titleTextStyle: TextStyle(
          color: Color(0xFF2C2C2C),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Color(0xFF007AFF),
        unselectedLabelColor: Color(0xFF8E8E93),
        indicatorSize: TabBarIndicatorSize.tab,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2C2C2C),
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C2C2C),
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFF2C2C2C),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF2C2C2C),
        ),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF007AFF),
        primary: const Color(0xFF007AFF),
        secondary: const Color(0xFF5856D6),
        surface: Colors.white,
        background: Colors.white,
        error: const Color(0xFFFF3B30),
      ),
    );
  }
}