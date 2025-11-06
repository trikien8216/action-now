import 'package:flutter/material.dart';

final vibrantTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFF6B6B),     // Đỏ hồng coral
    onPrimary: Colors.white,
    secondary: Color(0xFFFFE66D),   // Vàng sáng
    onSecondary: Color(0xFF1E1E1E),
    surface: Colors.white,
    onSurface: Color(0xFF1E1E1E),
    error: Color(0xFFE53935),
    onError: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFFFFDF5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFFFF6B6B)),
    titleTextStyle: TextStyle(
      color: Color(0xFF1E1E1E),
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFF6B6B),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFF6B6B),
    foregroundColor: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF1E1E1E)),
    bodyMedium: TextStyle(color: Color(0xFF5F6368)),
    titleLarge: TextStyle(
      color: Color(0xFF1E1E1E),
      fontWeight: FontWeight.bold,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  ),
);
