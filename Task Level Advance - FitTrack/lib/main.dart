import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/user_profile_provider.dart';
import 'core/providers/activity_provider.dart';
import 'core/providers/goals_provider.dart';
import 'core/providers/settings_provider.dart';
import 'core/services/local_storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'main_shell.dart';

/// Application entry point.
/// Initialises local storage, then runs the app wrapped in all Providers.
Future<void> main() async {
  // Required for async work before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise SharedPreferences so all providers can read persisted data
  await LocalStorageService.initialize();

  runApp(const FitTrackApp());
}

/// Root widget. Configures Provider tree and theme.
class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider supplies state to the entire widget tree.
    // Each ChangeNotifierProvider creates exactly one instance that is
    // shared across all widgets – the "single source of truth" pattern.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        // Consumer rebuilds only when theme changes, not the whole tree
        builder: (_, themeProvider, __) {
          return MaterialApp(
            title: 'FitTrack Pro',
            debugShowCheckedModeBanner: false,

            // Light and dark themes defined in AppTheme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            // Named routes for clean navigation
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/home': (_) => const MainShell(),
              '/history': (_) => const HistoryScreen(),
              '/profile': (_) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}
