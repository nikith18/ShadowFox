import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../models/calculator_state.dart';
import '../providers/calculator_provider.dart';
import '../widgets/calc_button.dart';
import '../widgets/display_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/theme_toggle.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final CalculatorProvider calculator = context.read<CalculatorProvider>();
    final LogicalKeyboardKey key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      calculator.onButtonPressed('=');
    } else if (key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete) {
      calculator.onButtonPressed(CalculatorProvider.backspace);
    } else if (key == LogicalKeyboardKey.escape) {
      calculator.onButtonPressed('AC');
    } else if (key == LogicalKeyboardKey.numpadAdd) {
      calculator.onButtonPressed('+');
    } else if (key == LogicalKeyboardKey.numpadSubtract) {
      calculator.onButtonPressed('-');
    } else if (key == LogicalKeyboardKey.numpadMultiply) {
      calculator.onButtonPressed(CalculatorProvider.multiply);
    } else if (key == LogicalKeyboardKey.numpadDivide) {
      calculator.onButtonPressed(CalculatorProvider.divide);
    } else if (key == LogicalKeyboardKey.numpadDecimal) {
      calculator.onButtonPressed('.');
    } else if (event.character != null) {
      final String character = event.character!;
      final String? calculatorKey = switch (character) {
        '*' => CalculatorProvider.multiply,
        '/' => CalculatorProvider.divide,
        '+' => '+',
        '-' => '-',
        '%' => '%',
        '=' => '=',
        '.' => '.',
        _ when RegExp(r'^\d$').hasMatch(character) => character,
        _ => null,
      };
      if (calculatorKey == null) return KeyEventResult.ignored;
      calculator.onButtonPressed(calculatorKey);
    } else {
      return KeyEventResult.ignored;
    }

    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Stack(
          children: [
            _GradientBackground(isDark: isDark),
            const _DecorativeOrb(
              alignment: Alignment(-1.15, -0.98),
              color: AppColors.accentPurple,
            ),
            const _DecorativeOrb(
              alignment: Alignment(1.15, 0.9),
              color: AppColors.accentBlue,
            ),
            SafeArea(
              child: Column(
                children: [
                  const _TopBar(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool splitLayout =
                            constraints.maxWidth >= 760 ||
                            constraints.maxWidth > constraints.maxHeight;

                        return _ResponsiveCalculatorLayout(
                          splitLayout: splitLayout,
                          constraints: constraints,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final CalculatorProvider calculator = context
            .watch<CalculatorProvider>();
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final bool compact = constraints.maxWidth < 440;
        final Color foreground = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceLG,
            AppSizes.spaceSM,
            AppSizes.spaceLG,
            AppSizes.spaceSM,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  gradient: const LinearGradient(
                    colors: [AppColors.accentPurple, AppColors.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.accentPurple,
                      blurRadius: 18,
                      spreadRadius: -8,
                    ),
                  ],
                ),
                child: const Icon(Icons.calculate_rounded, color: Colors.white),
              ),
              const SizedBox(width: AppSizes.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SmartCalc',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (!compact)
                      Text(
                        'Fast, focused, beautifully simple',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: foreground.withValues(alpha: 0.58),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              if (compact)
                IconButton(
                  tooltip: 'Scientific mode',
                  onPressed: calculator.toggleScientificMode,
                  icon: Icon(
                    Icons.auto_awesome_rounded,
                    color: calculator.state.isScientificMode
                        ? AppColors.accentPurple
                        : foreground.withValues(alpha: 0.72),
                  ),
                )
              else
                FilterChip(
                  selected: calculator.state.isScientificMode,
                  label: const Text('Scientific'),
                  avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                  onSelected: (_) => calculator.toggleScientificMode(),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
              const SizedBox(width: AppSizes.spaceSM),
              const ThemeToggle(),
            ],
          ),
        );
      },
    );
  }
}

class _ResponsiveCalculatorLayout extends StatelessWidget {
  final bool splitLayout;
  final BoxConstraints constraints;

  const _ResponsiveCalculatorLayout({
    required this.splitLayout,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final Widget display = const DisplayScreen();
    final Widget keypad = const _Keypad();

    if (!splitLayout) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.spaceLG,
              AppSizes.spaceSM,
              AppSizes.spaceLG,
              AppSizes.spaceLG,
            ),
            child: Column(
              children: [
                Flexible(flex: 3, child: display),
                const SizedBox(height: AppSizes.spaceMD),
                Flexible(flex: 7, child: keypad),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spaceXL,
            AppSizes.spaceSM,
            AppSizes.spaceXL,
            AppSizes.spaceXL,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: constraints.maxWidth >= 1100 ? 5 : 4,
                child: Center(child: display),
              ),
              const SizedBox(width: AppSizes.spaceLG),
              Expanded(flex: 5, child: keypad),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeyDefinition {
  final String label;
  final ButtonType type;

  const _KeyDefinition(this.label, this.type);
}

class _Keypad extends StatelessWidget {
  static const List<_KeyDefinition> _basicKeys = [
    _KeyDefinition('AC', ButtonType.utility),
    _KeyDefinition(CalculatorProvider.plusMinus, ButtonType.utility),
    _KeyDefinition('%', ButtonType.utility),
    _KeyDefinition(CalculatorProvider.divide, ButtonType.operator),
    _KeyDefinition('7', ButtonType.number),
    _KeyDefinition('8', ButtonType.number),
    _KeyDefinition('9', ButtonType.number),
    _KeyDefinition(CalculatorProvider.multiply, ButtonType.operator),
    _KeyDefinition('4', ButtonType.number),
    _KeyDefinition('5', ButtonType.number),
    _KeyDefinition('6', ButtonType.number),
    _KeyDefinition('-', ButtonType.operator),
    _KeyDefinition('1', ButtonType.number),
    _KeyDefinition('2', ButtonType.number),
    _KeyDefinition('3', ButtonType.number),
    _KeyDefinition('+', ButtonType.operator),
    _KeyDefinition(CalculatorProvider.backspace, ButtonType.delete),
    _KeyDefinition('0', ButtonType.number),
    _KeyDefinition('.', ButtonType.decimal),
    _KeyDefinition('=', ButtonType.equals),
  ];

  static const List<_KeyDefinition> _scientificKeys = [
    _KeyDefinition('sin', ButtonType.utility),
    _KeyDefinition('cos', ButtonType.utility),
    _KeyDefinition('tan', ButtonType.utility),
    _KeyDefinition('sqrt', ButtonType.utility),
    _KeyDefinition('log', ButtonType.utility),
    _KeyDefinition('ln', ButtonType.utility),
    _KeyDefinition('x²', ButtonType.utility),
    _KeyDefinition('!', ButtonType.utility),
  ];

  const _Keypad();

  @override
  Widget build(BuildContext context) {
    final CalculatorProvider calculator = context.watch<CalculatorProvider>();
    final List<_KeyDefinition> keys = [
      if (calculator.state.isScientificMode) ..._scientificKeys,
      ..._basicKeys,
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSizes.spaceSM),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: keys.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppSizes.spaceSM,
              mainAxisSpacing: AppSizes.spaceSM,
              childAspectRatio: _childAspectRatio(constraints, keys.length),
            ),
            itemBuilder: (context, index) {
              final _KeyDefinition key = keys[index];
              final String action = switch (key.label) {
                'x²' => 'pow',
                '!' => 'factorial',
                _ => key.label,
              };

              return CalcButton(
                label: key.label,
                type: key.type,
                onPressed: () => calculator.onButtonPressed(action),
                onLongPress: key.label == CalculatorProvider.backspace
                    ? calculator.onDeleteLongPress
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  double _childAspectRatio(BoxConstraints constraints, int keyCount) {
    final int rowCount = (keyCount / 4).ceil();
    final double itemWidth =
        (constraints.maxWidth - (AppSizes.spaceSM * 3)) / 4;
    final double itemHeight =
        (constraints.maxHeight - (AppSizes.spaceSM * (rowCount - 1))) /
        rowCount;
    if (itemHeight <= 0) return 1.08;
    return (itemWidth / itemHeight).clamp(0.78, 1.45).toDouble();
  }
}

class _GradientBackground extends StatelessWidget {
  final bool isDark;

  const _GradientBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [AppColors.darkBgTop, AppColors.darkBgBottom]
              : const [AppColors.lightBgTop, AppColors.lightBgBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  final Alignment alignment;
  final Color color;

  const _DecorativeOrb({required this.alignment, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: FractionallySizedBox(
          widthFactor: 0.6,
          heightFactor: 0.4,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: isDark ? 0.10 : 0.07),
            ),
          ),
        ),
      ),
    );
  }
}
