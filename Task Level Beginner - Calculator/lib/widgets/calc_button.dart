import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';
import '../models/calculator_state.dart';

/// An animated, glassmorphism-styled calculator button.
///
/// Features:
///   • Scale-down animation on press (micro-interaction for tactile feel)
///   • Haptic feedback on touch
///   • Different colours for [ButtonType.operator], [ButtonType.equals],
///     [ButtonType.utility], [ButtonType.number], [ButtonType.delete]
///   • Ink ripple inside a glass-tint container
///   • Fully responsive – sizes itself to the available space via [AspectRatio]
///
/// Flutter's widget tree is inherently lighter than Android's View hierarchy.
/// Unlike Android LinearLayouts which re-measure children multiple times,
/// Flutter's layout protocol guarantees at most one pass per widget — so
/// having many buttons here is NOT a performance concern.
class CalcButton extends StatefulWidget {
  final String label;
  final ButtonType type;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;

  const CalcButton({
    super.key,
    required this.label,
    required this.type,
    required this.onPressed,
    this.onLongPress,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Short duration keeps the animation snappy; 120ms feels responsive.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) async {
    HapticFeedback.lightImpact(); // Tactile feedback
    await _controller.forward();
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    await _controller.reverse();
    widget.onPressed();
  }

  Future<void> _onTapCancel() async {
    await _controller.reverse();
  }

  // ──────────────────────────────────────────────
  //  COLOR HELPERS
  // ──────────────────────────────────────────────

  Color _resolveBackground(bool isDark) {
    switch (widget.type) {
      case ButtonType.operator:
        return AppColors.darkOperatorBg; // Same in both modes – vibrant purple
      case ButtonType.utility:
        return isDark ? AppColors.darkUtilityBg : AppColors.lightUtilityBg;
      case ButtonType.delete:
        return AppColors.deleteColor.withValues(alpha: 0.85);
      case ButtonType.equals:
        // Handled separately via gradient
        return Colors.transparent;
      case ButtonType.number:
      case ButtonType.decimal:
        return isDark ? AppColors.darkNumberBg : AppColors.lightNumberBg;
    }
  }

  Color _resolveTextColor(bool isDark) {
    switch (widget.type) {
      case ButtonType.operator:
      case ButtonType.equals:
      case ButtonType.delete:
        return Colors.white;
      case ButtonType.utility:
        return isDark ? Colors.white : AppColors.lightTextPrimary;
      case ButtonType.number:
      case ButtonType.decimal:
        return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
  }

  // ──────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = _resolveBackground(isDark);
    final Color textColor = _resolveTextColor(isDark);

    return AspectRatio(
      aspectRatio: AppSizes.buttonAspectRatio,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: _ButtonBody(
            type: widget.type,
            label: widget.label,
            bg: bg,
            textColor: textColor,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// Separates button body into its own widget so Flutter can const-optimise
/// buttons whose appearance doesn't change between rebuilds.
class _ButtonBody extends StatelessWidget {
  final ButtonType type;
  final String label;
  final Color bg;
  final Color textColor;
  final bool isDark;

  const _ButtonBody({
    required this.type,
    required this.label,
    required this.bg,
    required this.textColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEquals = type == ButtonType.equals;

    return Container(
      margin: const EdgeInsets.all(AppSizes.spaceXS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        // Gradient for equals button; flat colour for all others
        gradient: isEquals
            ? const LinearGradient(
                colors: [
                  AppColors.darkEqualsBgStart,
                  AppColors.darkEqualsBgEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEquals ? null : bg,
        boxShadow: [
          BoxShadow(
            color: isEquals
                ? AppColors.accentBlue.withValues(alpha: 0.35)
                : (type == ButtonType.operator
                      ? AppColors.accentPurple.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: isDark ? 0.3 : 0.1)),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.4),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          // onTap is a no-op here – GestureDetector handles the press logic
          // but InkWell provides the ripple visual
          onTap: () {},
          child: Center(
            child: _ButtonLabel(label: label, textColor: textColor),
          ),
        ),
      ),
    );
  }
}

/// The text label for a button. Uses [FittedBox] so the text automatically
/// scales down on smaller screens without overflowing.
class _ButtonLabel extends StatelessWidget {
  final String label;
  final Color textColor;

  const _ButtonLabel({required this.label, required this.textColor});

  @override
  Widget build(BuildContext context) {
    final bool isSymbol =
        '+-×÷%='.contains(label) || label == '⌫' || label == '±';

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceSM),
        child: label == '⌫'
            ? Icon(
                Icons.backspace_outlined,
                color: textColor,
                size: AppTypography.buttonFontSizeLarge,
              )
            : Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: isSymbol
                      ? AppTypography.buttonFontSizeLarge
                      : AppTypography.buttonFontSizeMedium,
                  fontWeight: AppTypography.buttonFontWeight,
                  height: 1.0,
                ),
              ),
      ),
    );
  }
}
