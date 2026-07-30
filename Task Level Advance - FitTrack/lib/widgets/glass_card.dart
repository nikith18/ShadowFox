import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// A reusable frosted-glass card using BackdropFilter + blur.
/// Wrapped in RepaintBoundary so the blur layer is isolated from the
/// parent render tree – this prevents unnecessary repaints and keeps
/// animations that run on top of the card at 60fps.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? borderColor;
  final Gradient? gradient;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.blurSigma = 8.0,
    this.borderColor,
    this.gradient,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);
    final effectiveBorderColor = borderColor ??
        (isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight);
    final effectiveGradient = gradient ??
        (isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight);

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        margin: margin,
        child: ClipRRect(
          borderRadius: effectiveBorderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: effectiveGradient,
                borderRadius: effectiveBorderRadius,
                border: showBorder
                    ? Border.all(color: effectiveBorderColor, width: 1.0)
                    : null,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
