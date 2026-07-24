import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_typography.dart';
import '../providers/calculator_provider.dart';
import 'glass_card.dart';

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return GlassCard(
      blurSigma: AppSizes.blurLG,
      padding: const EdgeInsets.all(AppSizes.spaceXL),
      child: Consumer<CalculatorProvider>(
        builder: (context, calculator, _) {
          final state = calculator.state;
          final bool hasExpression = state.expression.isNotEmpty;
          final bool hasError = _isError(state.result);

          return LayoutBuilder(
            builder: (context, constraints) {
              final double resultSize = constraints.maxWidth < 360
                  ? AppTypography.displayFontSizeSmall
                  : constraints.maxWidth < 500
                  ? AppTypography.displayFontSizeMedium
                  : AppTypography.displayFontSizeLarge;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _StatusPill(
                        label: state.isScientificMode
                            ? 'SCIENTIFIC MODE'
                            : 'LIVE PREVIEW',
                        color: state.isScientificMode
                            ? AppColors.accentPurple
                            : AppColors.accentBlue,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Copy answer',
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: state.result));
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                content: Text('Answer copied'),
                                duration: Duration(milliseconds: 900),
                              ),
                            );
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          color: secondary,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Align(
                      key: ValueKey(state.expression),
                      alignment: Alignment.centerRight,
                      child: Text(
                        hasExpression
                            ? state.expression
                            : 'Ready for your next calculation',
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasExpression
                              ? secondary
                              : secondary.withValues(alpha: 0.65),
                          fontSize: hasExpression
                              ? AppTypography.expressionFontSize
                              : 14,
                          fontWeight: hasExpression
                              ? AppTypography.expressionFontWeight
                              : FontWeight.w500,
                          letterSpacing: hasExpression ? 0.5 : 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceMD),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.18),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: Align(
                      key: ValueKey(state.result),
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          state.result,
                          style: TextStyle(
                            color: hasError ? AppColors.errorColor : primary,
                            fontSize: resultSize,
                            fontWeight: AppTypography.displayFontWeight,
                            letterSpacing: -1.2,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  bool _isError(String value) =>
      value == 'Error' ||
      value == 'Invalid expression' ||
      value == 'Cannot divide by zero' ||
      value == 'Overflow';
}

class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
