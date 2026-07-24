// main.dart
// ────────────────────────────────────────────────────────────────
// Entry point for the Smart Login Flutter Application.
//
// Architecture overview:
//   ┌───────────────────────────────────────────────────────┐
//   │  main()                                               │
//   │   └─ SmartLoginApp  (StatefulWidget)                  │
//   │       └─ MaterialApp  (theme switching)               │
//   │           └─ LoginScreen  ──────► WelcomeScreen       │
//   │               (pushReplacement)   (pushReplacement)   │
//   └───────────────────────────────────────────────────────┘
//
// STATE MANAGEMENT STRATEGY:
//   LoginViewModel is created once here and passed to screens via
//   constructor injection. The ViewModel survives widget rebuilds
//   (including device rotation) because it lives in the State of
//   SmartLoginApp — above the MaterialApp in the widget tree.
//
// STARTUP FLOW:
//   1. _SmartLoginAppState._initApp() – calls
//      viewModel.loadPersistedSession() which:
//        • restores rememberMe + username from SharedPreferences
//        • checks biometric hardware availability
//      If a persisted session is found AND the device has biometrics,
//      the user is prompted to unlock via fingerprint/face before
//      being taken straight to WelcomeScreen.
//
// DARK MODE (BONUS):
//   The ViewModel holds an [isDarkMode] flag. SmartLoginApp listens
//   to the ViewModel and switches ThemeMode.light/dark accordingly.
// ────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/login_screen.dart';
import 'viewmodels/login_viewmodel.dart';

// ── Program entry ───────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prefer portrait orientation on phones (optional UX decision).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const SmartLoginApp());
}

// ── Root widget ─────────────────────────────────────────────────
class SmartLoginApp extends StatefulWidget {
  const SmartLoginApp({super.key});

  @override
  State<SmartLoginApp> createState() => _SmartLoginAppState();
}

class _SmartLoginAppState extends State<SmartLoginApp> {
  /// A single ViewModel instance shared between all screens.
  /// Lives here (above MaterialApp) so it survives navigation.
  final LoginViewModel _viewModel = LoginViewModel();

  /// True while loadPersistedSession is running (shows splash).
  bool _initialising = true;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_onViewModelChanged);
    _initApp();
  }

  // ── Startup: SharedPreferences restore + biometric check ────────
  Future<void> _initApp() async {
    // Restore remember-me session and detect biometric hardware
    await _viewModel.loadPersistedSession();

    if (mounted) {
      setState(() => _initialising = false);
    }
  }

  void _onViewModelChanged() {
    // Rebuild MaterialApp when isDarkMode or other state changes.
    setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  // ── Material Design 3 Light Theme ────────────────────────────────
  ThemeData _buildLightTheme() {
    const seedColor = Color(0xFF4F46E5); // Indigo-600

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
      ),
    );
  }

  // ── Material Design 3 Dark Theme ─────────────────────────────────
  ThemeData _buildDarkTheme() {
    const seedColor = Color(0xFF818CF8); // Indigo-400

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a minimal splash while SharedPreferences loads (< 200 ms)
    if (_initialising) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: const Color(0xFF4F46E5)),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Simple Login Page',
      debugShowCheckedModeBanner: false,

      // ── Theme switching ──────────────────────────────────────────
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _viewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // ── Initial screen ────────────────────────────────────────────
      // If a remembered session was found, pass the ViewModel so that
      // LoginScreen can immediately navigate to WelcomeScreen (or show
      // the biometric prompt). Otherwise show the normal login screen.
      home: LoginScreen(viewModel: _viewModel),
    );
  }
}
