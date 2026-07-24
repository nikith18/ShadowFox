import 'package:flutter/material.dart';

class AppTheme {
  static const _fontFamily = 'Roboto';

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2196F3),
      brightness: Brightness.light,
      primary: const Color(0xFF1565C0),
      secondary: const Color(0xFF42A5F5),
      surface: const Color(0xFFEEF4FF),
      onSurface: const Color(0xFF0D1B2A),
    ),
    scaffoldBackgroundColor: const Color(0xFFDCEAFB),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFF0D1B2A),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF0D1B2A),
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: Color(0xFF0D1B2A),
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: Color(0xFF0D1B2A),
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF1A2D4A),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF1A2D4A),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Color(0xFF1A2D4A)),
      bodyMedium: TextStyle(color: Color(0xFF2C4260)),
      bodySmall: TextStyle(color: Color(0xFF4A6080)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3F51B5),
      brightness: Brightness.dark,
      primary: const Color(0xFF82B1FF),
      secondary: const Color(0xFF448AFF),
      surface: const Color(0xFF0D1B3E),
      onSurface: const Color(0xFFE8F0FF),
    ),
    scaffoldBackgroundColor: const Color(0xFF060D1F),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFFE8F0FF),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFFE8F0FF),
        fontWeight: FontWeight.bold,
      ),
      displayMedium: TextStyle(
        color: Color(0xFFE8F0FF),
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: Color(0xFFE8F0FF),
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFFCCD8F0),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Color(0xFFCCD8F0),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: Color(0xFFCCD8F0)),
      bodyMedium: TextStyle(color: Color(0xFFAABDD8)),
      bodySmall: TextStyle(color: Color(0xFF8899BB)),
    ),
  );
}
