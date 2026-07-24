// glass_card.dart
// ────────────────────────────────────────────────────────────────
// A reusable "liquid glass" container using BackdropFilter + blur.
// Any widget placed inside gets the frosted-glass effect behind it.
//
// Works in both light and dark themes automatically.
// ────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur,
    this.opacity,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double? blur;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? AppConstants.borderRadius;
    final blurSigma = blur ?? AppConstants.glassBlur;
    final fillOpacity = opacity ?? AppConstants.glassOpacity;

    // Glass fill colour: white gloss in dark, subtle tinted in light
    final fillColor = isDark
        ? Colors.white.withValues(alpha: fillOpacity)
        : Colors.white.withValues(alpha: fillOpacity + 0.35);

    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.22)
        : Colors.white.withValues(alpha: 0.75);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        // ← Gaussian blur of whatever is BEHIND this widget
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor,
              width: AppConstants.glassBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: 24,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(AppConstants.paddingLarge),
          child: child,
        ),
      ),
    );
  }
}
