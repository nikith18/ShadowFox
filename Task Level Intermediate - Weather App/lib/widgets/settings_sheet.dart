import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import 'glass_card.dart';

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _SettingsContent(),
  );
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final settings = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingRow(
            icon: Icons.thermostat,
            title: 'Use Fahrenheit',
            value: settings.isFahrenheit,
            onChanged: (val) => settings.toggleUnit(),
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _SettingRow(
            icon: Icons.animation,
            title: 'Reduce Motion',
            value: settings.reduceMotion,
            onChanged: (val) => settings.toggleMotion(),
            textColor: textColor,
          ),
          const SizedBox(height: 12),
          _SettingRow(
            icon: isDark ? Icons.dark_mode : Icons.light_mode,
            title: 'Dark Mode',
            value: isDark,
            onChanged: (val) => themeProvider.toggleTheme(),
            textColor: textColor,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color textColor;

  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: textColor.withValues(alpha: 0.8)),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blueAccent,
      ),
    );
  }
}
