import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';
import '../models/calculator_state.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press() {
    _controller.reverse();
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  Color _background(bool isDark) {
    switch (widget.type) {
      case ButtonType.operator:
        return isDark ? AppColors.darkOperatorBg : AppColors.lightOperatorBg;
      case ButtonType.utility:
        return isDark ? AppColors.darkUtilityBg : AppColors.lightUtilityBg;
      case ButtonType.delete:
        return AppColors.deleteColor.withValues(alpha: isDark ? 0.85 : 0.12);
      case ButtonType.equals:
        return Colors.transparent;
      case ButtonType.number:
      case ButtonType.decimal:
        return isDark ? AppColors.darkNumberBg : AppColors.lightNumberBg;
    }
  }

  Color _foreground(bool isDark) {
    switch (widget.type) {
      case ButtonType.operator:
      case ButtonType.equals:
        return Colors.white;
      case ButtonType.delete:
        return isDark ? Colors.white : AppColors.deleteColor;
      case ButtonType.utility:
        return isDark ? Colors.white : AppColors.lightTextPrimary;
      case ButtonType.number:
      case ButtonType.decimal:
        return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double scale = 1 - (_controller.value * 0.06);
        return Transform.scale(scale: scale, child: child);
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _press,
          onTapDown: (_) {
            HapticFeedback.selectionClick();
            _controller.forward();
          },
          onTapCancel: _controller.reverse,
          onLongPress: widget.onLongPress,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: _ButtonSurface(
            label: widget.label,
            type: widget.type,
            background: _background(isDark),
            foreground: _foreground(isDark),
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _ButtonSurface extends StatelessWidget {
  final String label;
  final ButtonType type;
  final Color background;
  final Color foreground;
  final bool isDark;

  const _ButtonSurface({
    required this.label,
    required this.type,
    required this.background,
    required this.foreground,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEquals = type == ButtonType.equals;

    return Container(
      margin: const EdgeInsets.all(AppSizes.spaceXS),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        color: isEquals ? null : background,
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
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color:
                (isEquals
                        ? AppColors.accentBlue
                        : type == ButtonType.operator
                        ? AppColors.accentPurple
                        : Colors.black)
                    .withValues(alpha: isDark ? 0.26 : 0.10),
            blurRadius: isEquals ? 16 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: _ButtonLabel(label: label, color: foreground),
      ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _ButtonLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool symbol = '+-×÷%='.contains(label) || label == '±';
    final Widget content = switch (label) {
      '⌫' => Icon(Icons.backspace_outlined, color: color, size: 24),
      'AC' => Text('AC', style: _style(18)),
      _ => Text(label, style: _style(symbol ? 28 : 22)),
    };

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.spaceSM),
        child: content,
      ),
    );
  }

  TextStyle _style(double size) => TextStyle(
    color: color,
    fontSize: size,
    fontWeight: AppTypography.buttonFontWeight,
    height: 1,
  );
}
