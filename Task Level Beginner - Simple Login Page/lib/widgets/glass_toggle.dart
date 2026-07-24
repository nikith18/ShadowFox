// glass_toggle.dart
// ────────────────────────────────────────────────────────────────
// Shared dark/light mode glass toggle switch.
// Extracted from login_screen.dart and register_screen.dart
// to eliminate duplication.
// ────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'glass_card.dart';

class GlassToggle extends StatelessWidget {
  const GlassToggle({super.key, required this.isDark, required this.onToggle});
  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        borderRadius: 30,
        blur: 16,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 16,
              color: isDark ? Colors.amber : Colors.orange,
            ),
            const SizedBox(width: 6),
            // Animated toggle track
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 40,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: isDark
                    ? const Color(0xFF6C63FF).withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.5),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment: isDark
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 18,
                  height: 18,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white : Colors.orange,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
