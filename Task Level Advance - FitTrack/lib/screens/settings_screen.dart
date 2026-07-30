import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/theme_provider.dart';
import '../core/providers/settings_provider.dart';
import '../core/providers/activity_provider.dart';
import '../core/services/local_storage_service.dart';
import '../widgets/glass_card.dart';

/// Settings Screen – theme toggle, units, sensor/dataset mode, and data management.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final settings = context.watch<SettingsProvider>();
    final activity = context.read<ActivityProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            children: [
              // ── Appearance ──
              _sectionHeader(context, '🎨 Appearance'),
              GlassCard(
                child: Column(
                  children: [
                    _switchTile(
                      context,
                      title: 'Dark Mode',
                      subtitle: 'Switch between light and dark themes',
                      icon: Icons.dark_mode,
                      value: theme.isDarkMode,
                      onChanged: (_) => theme.toggleTheme(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Units ──
              _sectionHeader(context, '📏 Units'),
              GlassCard(
                child: _switchTile(
                  context,
                  title: 'Use Kilometers',
                  subtitle: 'Toggle between km and miles',
                  icon: Icons.straighten,
                  value: settings.useKilometers,
                  onChanged: settings.setUseKilometers,
                ),
              ),

              const SizedBox(height: 16),

              // ── Data Mode ──
              _sectionHeader(context, '📊 Data Mode'),
              GlassCard(
                child: Column(
                  children: [
                    _switchTile(
                      context,
                      title: 'Dataset Mode',
                      subtitle: 'Load and analyze the bundled CSV dataset',
                      icon: Icons.table_chart,
                      value: settings.datasetEnabled,
                      onChanged: settings.setDatasetEnabled,
                    ),
                    const Divider(height: 1),
                    _switchTile(
                      context,
                      title: 'Sensor Mode',
                      subtitle: 'Use device sensors for live tracking',
                      icon: Icons.sensors,
                      value: settings.sensorEnabled,
                      onChanged: (v) {
                        settings.setSensorEnabled(v);
                        activity.setSensorMode(v);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Notifications ──
              _sectionHeader(context, '🔔 Notifications'),
              GlassCard(
                child: _switchTile(
                  context,
                  title: 'Enable Notifications',
                  subtitle: 'Daily reminders and goal alerts',
                  icon: Icons.notifications,
                  value: settings.notificationsEnabled,
                  onChanged: settings.setNotificationsEnabled,
                ),
              ),

              const SizedBox(height: 16),

              // ── Data Management ──
              _sectionHeader(context, '🗄️ Data Management'),
              GlassCard(
                child: Column(
                  children: [
                    ListTile(
                      leading:
                          const Icon(Icons.refresh, color: AppColors.accent),
                      title: const Text('Reload Dataset'),
                      subtitle: const Text('Re-import from bundled CSV'),
                      onTap: () {
                        activity.loadDataset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dataset reloaded!')),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading:
                          const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Clear All Data'),
                      subtitle:
                          const Text('Permanently removes all stored data'),
                      onTap: () => _confirmClearData(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── App Info ──
              _sectionHeader(context, 'ℹ️ About'),
              GlassCard(
                child: Column(
                  children: [
                    const ListTile(
                      leading:
                          Icon(Icons.fitness_center, color: AppColors.primary),
                      title: Text('FitTrack Pro'),
                      subtitle: Text('Version 1.0.0'),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.code, color: AppColors.accent),
                      title: Text('Built with Flutter'),
                      subtitle: Text('Material 3 · Provider · fl_chart'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    );
  }

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will permanently delete all goals, history, and settings. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await LocalStorageService.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared.')),
        );
      }
    }
  }
}
