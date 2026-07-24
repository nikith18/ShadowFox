import 'package:flutter/material.dart';

/// Central color palette for the Smart Modern Calculator.
/// All colors are defined here to maintain consistency across the app.
/// Inspired by Liquid Glass / Glassmorphism design language.
abstract class AppColors {
  // ──────────────────────────────────────────────
  //  DARK THEME COLORS
  // ──────────────────────────────────────────────

  /// Deep background gradient – top color
  static const Color darkBgTop = Color(0xFF0D0D1A);

  /// Deep background gradient – bottom color
  static const Color darkBgBottom = Color(0xFF1A0A2E);

  /// Glass card surface (dark)
  static const Color darkGlassSurface = Color(0x1AFFFFFF);

  /// Glass card border (dark)
  static const Color darkGlassBorder = Color(0x33FFFFFF);

  /// Display screen background (dark)
  static const Color darkDisplayBg = Color(0x0DFFFFFF);

  /// Primary text on dark background
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Secondary text on dark background (expression label)
  static const Color darkTextSecondary = Color(0xB3FFFFFF);

  /// Operator button color (dark) – vibrant violet
  static const Color darkOperatorBg = Color(0xFF7C3AED);

  /// Operator button splash (dark)
  static const Color darkOperatorSplash = Color(0xFF9D5FF3);

  /// Equals button color (dark) – electric purple-blue gradient start
  static const Color darkEqualsBgStart = Color(0xFF6D28D9);

  /// Equals button color (dark) – gradient end
  static const Color darkEqualsBgEnd = Color(0xFF2563EB);

  /// Utility button (AC, ±, %) in dark mode
  static const Color darkUtilityBg = Color(0x33FFFFFF);

  /// Number button in dark mode
  static const Color darkNumberBg = Color(0x1AFFFFFF);

  // ──────────────────────────────────────────────
  //  LIGHT THEME COLORS
  // ──────────────────────────────────────────────

  /// Light background gradient – top color
  static const Color lightBgTop = Color(0xFFF0F4FF);

  /// Light background gradient – bottom color
  static const Color lightBgBottom = Color(0xFFE8D5F5);

  /// Glass card surface (light)
  static const Color lightGlassSurface = Color(0x80FFFFFF);

  /// Glass card border (light)
  static const Color lightGlassBorder = Color(0xB3FFFFFF);

  /// Display screen background (light)
  static const Color lightDisplayBg = Color(0x33FFFFFF);

  /// Primary text on light background
  static const Color lightTextPrimary = Color(0xFF1A1A2E);

  /// Secondary text on light background
  static const Color lightTextSecondary = Color(0x991A1A2E);

  /// Operator button color (light) – vibrant violet
  static const Color lightOperatorBg = Color(0xFF7C3AED);

  /// Utility button (AC, ±, %) in light mode
  static const Color lightUtilityBg = Color(0xFFD1C4E9);

  /// Number button in light mode
  static const Color lightNumberBg = Color(0xB3FFFFFF);

  // ──────────────────────────────────────────────
  //  SHARED / SEMANTIC COLORS
  // ──────────────────────────────────────────────

  /// Error text color
  static const Color errorColor = Color(0xFFFF5252);

  /// Accent purple – used for glow effects
  static const Color accentPurple = Color(0xFF7C3AED);

  /// Accent blue – used for equals gradient
  static const Color accentBlue = Color(0xFF2563EB);

  /// Delete button red tint
  static const Color deleteColor = Color(0xFFEF4444);
}
