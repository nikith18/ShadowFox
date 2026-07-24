import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// A frosted-glass card widget.
///
/// Uses [BackdropFilter] + [ImageFilter.blur] to achieve the glassmorphism
/// effect. The border and semi-transparent background simulate frosted glass.
///
/// NOTE: [BackdropFilter] is expensive – use it sparingly. Here it is used
/// only twice: once for the main display and once for the button grid card.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.blurSigma = AppSizes.blurMD,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final double radius = borderRadius ?? AppSizes.radiusLG;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            // Semi-transparent fill – lighter in dark mode, whiter in light mode
            color: isDark
                ? AppColors.darkGlassSurface
                : AppColors.lightGlassSurface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isDark
                  ? AppColors.darkGlassBorder
                  : AppColors.lightGlassBorder,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                blurRadius: AppSizes.shadowBlurRadius,
                spreadRadius: AppSizes.shadowSpreadRadius,
              ),
            ],
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
