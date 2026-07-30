import 'package:flutter/material.dart';

/// Centralized color palette for FitTrack Pro.
/// Using a dedicated color file ensures visual consistency across all screens.
class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D36CC);

  // Secondary accent
  static const Color accent = Color(0xFF00D4FF);
  static const Color accentLight = Color(0xFF66E7FF);

  // Success / health green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);

  // Warning / orange
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFB74D);

  // Error / red
  static const Color error = Color(0xFFEF5350);

  // Energy / calories – warm gradient
  static const Color calories = Color(0xFFFF6B6B);
  static const Color caloriesLight = Color(0xFFFF8A80);

  // Distance – teal
  static const Color distance = Color(0xFF26C6DA);
  static const Color distanceLight = Color(0xFF4DD0E1);

  // Steps – purple
  static const Color steps = Color(0xFFAB47BC);
  static const Color stepsLight = Color(0xFFCE93D8);

  // Active minutes – green
  static const Color activeMinutes = Color(0xFF66BB6A);

  // Heart rate – red
  static const Color heartRate = Color(0xFFF44336);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF3D36CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkBgGradient = LinearGradient(
    colors: [Color(0xFF0D0D1A), Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBgGradient = LinearGradient(
    colors: [Color(0xFFEEF2FF), Color(0xFFF5F7FF), Color(0xFFE8EDFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0x336C63FF), Color(0x1A3D36CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Color(0x1A6C63FF), Color(0x0D3D36CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stepsGradient = LinearGradient(
    colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient caloriesGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient distanceGradient = LinearGradient(
    colors: [Color(0xFF26C6DA), Color(0xFF00838F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient activeGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glass / frosted colors
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x40FFFFFF);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF0D0D1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF16213E);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFEEF2FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F7FF);

  // Text
  static const Color textDark = Color(0xFFFFFFFF);
  static const Color textDarkSecondary = Color(0xFFB0B0CC);
  static const Color textLight = Color(0xFF1A1A2E);
  static const Color textLightSecondary = Color(0xFF6B6B8A);
}
