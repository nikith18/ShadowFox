import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../constants/app_colors.dart';

/// Animated theme toggle switch displayed in the AppBar.
///
/// Uses [AnimatedContainer] + [AnimatedPositioned] to smoothly slide
/// the "thumb" between dark and light positions, with icon transitions
/// between moon (dark) and sun (light) via [AnimatedSwitcher].
class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final bool isDark = themeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => context.read<ThemeProvider>().toggleTheme(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: 64,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? AppColors.accentPurple.withValues(alpha: 0.5)
                : AppColors.lightUtilityBg,
            border: Border.all(
              color: isDark
                  ? AppColors.darkGlassBorder
                  : AppColors.lightGlassBorder,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // The sliding thumb
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: isDark ? 2 : 34,
                top: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.accentPurple : Colors.amber,
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppColors.accentPurple : Colors.amber)
                            .withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      key: ValueKey(isDark),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
