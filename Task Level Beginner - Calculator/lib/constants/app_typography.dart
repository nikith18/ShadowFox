import 'package:flutter/material.dart';

/// Typography constants for the Smart Modern Calculator.
/// Centralised here so font sizes and weights can be tuned from one place.
abstract class AppTypography {
  // ──────────────────────────────────────────────
  //  DISPLAY (result number on screen)
  // ──────────────────────────────────────────────

  static const double displayFontSizeLarge = 56.0;
  static const double displayFontSizeMedium = 44.0;
  static const double displayFontSizeSmall = 34.0;

  static const FontWeight displayFontWeight = FontWeight.w300;

  // ──────────────────────────────────────────────
  //  EXPRESSION (the input expression above result)
  // ──────────────────────────────────────────────

  static const double expressionFontSize = 22.0;
  static const FontWeight expressionFontWeight = FontWeight.w400;

  // ──────────────────────────────────────────────
  //  BUTTON LABELS
  // ──────────────────────────────────────────────

  static const double buttonFontSizeLarge = 26.0;
  static const double buttonFontSizeMedium = 22.0;
  static const double buttonFontSizeSmall = 18.0;
  static const FontWeight buttonFontWeight = FontWeight.w500;

  // ──────────────────────────────────────────────
  //  MISC
  // ──────────────────────────────────────────────

  static const double appBarTitleFontSize = 18.0;
  static const FontWeight appBarFontWeight = FontWeight.w600;

  static const String fontFamily = 'Roboto'; // System sans-serif fallback
}
