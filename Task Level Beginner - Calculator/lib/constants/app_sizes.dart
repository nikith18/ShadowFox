/// Responsive size constants and layout breakpoints.
/// Using named constants instead of magic numbers improves readability
/// and makes responsive adjustments much easier.
abstract class AppSizes {
  // ──────────────────────────────────────────────
  //  BREAKPOINTS
  // ──────────────────────────────────────────────

  /// Minimum width considered a "small" phone (e.g., SE-sized)
  static const double smallPhone = 360.0;

  /// Width at which tablet layout kicks in
  static const double tabletBreakpoint = 600.0;

  // ──────────────────────────────────────────────
  //  SPACING
  // ──────────────────────────────────────────────

  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 12.0;
  static const double spaceLG = 16.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;

  // ──────────────────────────────────────────────
  //  BORDER RADIUS
  // ──────────────────────────────────────────────

  static const double radiusSM = 12.0;
  static const double radiusMD = 20.0;
  static const double radiusLG = 28.0;
  static const double radiusXL = 36.0;
  static const double radiusFull = 100.0; // pill shape

  // ──────────────────────────────────────────────
  //  BUTTON SIZES
  // ──────────────────────────────────────────────

  /// Minimum button touch target (accessibility guideline: 48×48)
  static const double minTouchTarget = 56.0;

  /// Aspect ratio for square calculator buttons
  static const double buttonAspectRatio = 1.0;

  // ──────────────────────────────────────────────
  //  GLASS BLUR
  // ──────────────────────────────────────────────

  static const double blurSM = 8.0;
  static const double blurMD = 16.0;
  static const double blurLG = 24.0;

  // ──────────────────────────────────────────────
  //  ELEVATION / SHADOW
  // ──────────────────────────────────────────────

  static const double shadowBlurRadius = 24.0;
  static const double shadowSpreadRadius = 2.0;
}
