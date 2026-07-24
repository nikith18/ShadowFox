import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/calculator_provider.dart';
import '../models/calculator_state.dart';
import '../constants/app_sizes.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_screen.dart';
import '../widgets/theme_toggle.dart';
import '../widgets/glass_card.dart';

/// The main calculator screen that orchestrates all child widgets.
///
/// Responsible for:
///   • Rendering the gradient background
///   • Laying out the display panel and button grid responsively
///   • Adapting to portrait / landscape / tablet orientations
///   • Hosting the AppBar with the theme toggle
///
/// NOTE: This widget contains NO business logic. All computation is
/// delegated to [CalculatorProvider] (clean architecture principle).
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  // ──────────────────────────────────────────────
  //  BUTTON LAYOUT DEFINITION
  // ──────────────────────────────────────────────

  /// Button grid definition. Each inner list represents one row.
  /// Order: row-by-row, left-to-right.
  static const List<List<Map<String, dynamic>>> _buttonRows = [
    [
      {'label': 'AC', 'type': ButtonType.utility},
      {'label': '±', 'type': ButtonType.utility},
      {'label': '%', 'type': ButtonType.utility},
      {'label': '÷', 'type': ButtonType.operator},
    ],
    [
      {'label': '7', 'type': ButtonType.number},
      {'label': '8', 'type': ButtonType.number},
      {'label': '9', 'type': ButtonType.number},
      {'label': '×', 'type': ButtonType.operator},
    ],
    [
      {'label': '4', 'type': ButtonType.number},
      {'label': '5', 'type': ButtonType.number},
      {'label': '6', 'type': ButtonType.number},
      {'label': '-', 'type': ButtonType.operator},
    ],
    [
      {'label': '1', 'type': ButtonType.number},
      {'label': '2', 'type': ButtonType.number},
      {'label': '3', 'type': ButtonType.number},
      {'label': '+', 'type': ButtonType.operator},
    ],
    [
      {'label': '⌫', 'type': ButtonType.delete},
      {'label': '0', 'type': ButtonType.number},
      {'label': '.', 'type': ButtonType.decimal},
      {'label': '=', 'type': ButtonType.equals},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final calc = context.read<CalculatorProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context, isDark),
      body: Stack(
        children: [
          // ── Gradient background ──
          _GradientBackground(isDark: isDark),

          // ── Decorative accent blobs ──
          _AccentBlob(
            offset: const Offset(-80, -60),
            color: AppColors.accentPurple,
            isDark: isDark,
          ),
          _AccentBlob(
            offset: const Offset(200, 500),
            color: AppColors.accentBlue,
            isDark: isDark,
          ),

          // ── Main content ──
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isLandscape =
                    constraints.maxWidth > constraints.maxHeight;
                final bool isTablet =
                    constraints.maxWidth >= AppSizes.tabletBreakpoint;

                if (isLandscape) {
                  return _LandscapeLayout(
                    buttonRows: _buttonRows,
                    calc: calc,
                    isDark: isDark,
                  );
                }

                return _PortraitLayout(
                  buttonRows: _buttonRows,
                  calc: calc,
                  isDark: isDark,
                  isTablet: isTablet,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      title: Text(
        '✦ Smart Calc',
        style: TextStyle(
          fontSize: AppTypography.appBarTitleFontSize,
          fontWeight: AppTypography.appBarFontWeight,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          letterSpacing: 1.5,
        ),
      ),
      actions: const [ThemeToggle()],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  LAYOUT VARIANTS
// ──────────────────────────────────────────────────────────────────────────

/// Portrait layout: display on top, button grid below.
class _PortraitLayout extends StatelessWidget {
  final List<List<Map<String, dynamic>>> buttonRows;
  final CalculatorProvider calc;
  final bool isDark;
  final bool isTablet;

  const _PortraitLayout({
    required this.buttonRows,
    required this.calc,
    required this.isDark,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    // Constrain max width on tablets so content doesn't stretch too wide
    final double maxWidth = isTablet ? 480 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceLG,
            vertical: AppSizes.spaceSM,
          ),
          child: Column(
            children: [
              // Display panel – takes remaining space above buttons
              const Expanded(flex: 3, child: Center(child: DisplayScreen())),

              const SizedBox(height: AppSizes.spaceMD),

              // Button grid – fixed ratio so buttons are always square
              Expanded(
                flex: 5,
                child: _ButtonGrid(buttonRows: buttonRows, calc: calc),
              ),

              const SizedBox(height: AppSizes.spaceSM),
            ],
          ),
        ),
      ),
    );
  }
}

/// Landscape layout: display on the left, buttons on the right.
class _LandscapeLayout extends StatelessWidget {
  final List<List<Map<String, dynamic>>> buttonRows;
  final CalculatorProvider calc;
  final bool isDark;

  const _LandscapeLayout({
    required this.buttonRows,
    required this.calc,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spaceLG),
      child: Row(
        children: [
          // Display panel
          const Expanded(
            flex: 4,
            child: Align(alignment: Alignment.center, child: DisplayScreen()),
          ),

          const SizedBox(width: AppSizes.spaceMD),

          // Button grid
          Expanded(
            flex: 5,
            child: _ButtonGrid(buttonRows: buttonRows, calc: calc),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  BUTTON GRID
// ──────────────────────────────────────────────────────────────────────────

class _ButtonGrid extends StatelessWidget {
  final List<List<Map<String, dynamic>>> buttonRows;
  final CalculatorProvider calc;

  const _ButtonGrid({required this.buttonRows, required this.calc});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.spaceSM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: buttonRows.map((row) {
          return Expanded(
            child: Row(
              children: row.map((btn) {
                final String label = btn['label'] as String;
                final ButtonType type = btn['type'] as ButtonType;
                return Expanded(
                  child: CalcButton(
                    label: label,
                    type: type,
                    onPressed: () => calc.onButtonPressed(label),
                    // Long-press on delete clears everything
                    onLongPress: label == '⌫'
                        ? () => calc.onDeleteLongPress()
                        : null,
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────
//  DECORATIVE WIDGETS
// ──────────────────────────────────────────────────────────────────────────

/// Animated gradient background that fills the entire screen.
class _GradientBackground extends StatelessWidget {
  final bool isDark;
  const _GradientBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkBgTop, AppColors.darkBgBottom]
              : [AppColors.lightBgTop, AppColors.lightBgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

/// Blurred, semi-transparent accent blob for depth effect.
/// These are purely decorative and do not affect layout.
class _AccentBlob extends StatelessWidget {
  final Offset offset;
  final Color color;
  final bool isDark;

  const _AccentBlob({
    required this.offset,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: IgnorePointer(
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: isDark ? 0.12 : 0.08),
          ),
        ),
      ),
    );
  }
}
