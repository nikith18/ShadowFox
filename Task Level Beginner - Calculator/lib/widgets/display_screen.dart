import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_sizes.dart';
import '../widgets/glass_card.dart';

/// The main display panel of the calculator.
///
/// Shows two lines:
///   1. The current expression (dimmer, smaller)
///   2. The running result or final answer (large, bright)
///
/// [AnimatedSwitcher] wraps the result text so when the value changes
/// it plays a smooth fade + slide animation instead of an abrupt jump.
///
/// Auto-scales result font size via [FittedBox] so long numbers never overflow.
class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return GlassCard(
      blurSigma: AppSizes.blurLG,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spaceXL,
        vertical: AppSizes.spaceXL,
      ),
      child: Consumer<CalculatorProvider>(
        builder: (context, calc, _) {
          final state = calc.state;

          return SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Expression line ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: Text(
                    state.expression.isEmpty ? ' ' : state.expression,
                    key: ValueKey(state.expression),
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: AppTypography.expressionFontSize,
                      fontWeight: AppTypography.expressionFontWeight,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.spaceMD),

                // ── Result line ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                  child: SizedBox(
                    // Fixed height prevents layout jumps when font size changes
                    height: 70,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        state.result,
                        key: ValueKey(state.result),
                        style: TextStyle(
                          color: _resultColor(state.result, textPrimary),
                          fontSize: AppTypography.displayFontSizeLarge,
                          fontWeight: AppTypography.displayFontWeight,
                          letterSpacing: -1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Returns red for error states so the user immediately notices.
  Color _resultColor(String result, Color defaultColor) {
    if (result.startsWith('Error') ||
        result.startsWith('Cannot') ||
        result == 'Invalid Expression' ||
        result == 'Overflow') {
      return AppColors.errorColor;
    }
    return defaultColor;
  }
}
