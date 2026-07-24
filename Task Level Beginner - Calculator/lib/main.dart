import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'services/calculator_service.dart';
import 'services/preference_service.dart';

/// Application entry point.
///
/// Responsibilities:
///   1. Bootstrap Flutter engine bindings (required before any async work)
///   2. Initialise [SharedPreferences] via [PreferenceService]
///   3. Set preferred device orientations (portrait + landscape supported)
///   4. Provide [MultiProvider] with all application-level providers
///   5. Launch [SmartCalcApp]
///
/// Lifecycle observation is handled inside [_AppLifecycleObserver] (below),
/// which registers itself with [WidgetsBindingObserver] to receive
/// app foreground/background events without coupling them to the UI.
void main() async {
  // REQUIRED: must call this before any async operations in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise SharedPreferences and restore saved theme
  final PreferenceService prefs = await PreferenceService.getInstance();
  final bool savedDarkMode = prefs.getDarkMode();

  // Allow both portrait and landscape orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Optional: transparent status bar for immersive look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    // MultiProvider injects dependencies into the entire widget tree.
    // Providers are listed in dependency order (dependencies before dependents).
    MultiProvider(
      providers: [
        // ThemeProvider – depends on PreferenceService (already initialised)
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(
            preferenceService: prefs,
            initialDarkMode: savedDarkMode,
          ),
        ),

        // CalculatorProvider – depends on CalculatorService
        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) =>
              CalculatorProvider(calculatorService: CalculatorService()),
        ),
      ],
      child: const _LifecycleWrapper(),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────────────
//  LIFECYCLE WRAPPER
// ──────────────────────────────────────────────────────────────────────────

/// Wraps [SmartCalcApp] and implements [WidgetsBindingObserver] to receive
/// app lifecycle events.
///
/// Lifecycle states handled:
///   • [AppLifecycleState.resumed]   – App is visible and interactive
///   • [AppLifecycleState.inactive]  – App is partially obscured (e.g. incoming call)
///   • [AppLifecycleState.paused]    – App is in the background
///   • [AppLifecycleState.detached]  – App process is about to be terminated
///   • [AppLifecycleState.hidden]    – App is hidden (multi-window environments)
///
/// NOTE: We only log state transitions here. In a production app you could
/// use [resumed] to refresh data, [paused] to save state, etc.
class _LifecycleWrapper extends StatefulWidget {
  const _LifecycleWrapper();

  @override
  State<_LifecycleWrapper> createState() => _LifecycleWrapperState();
}

class _LifecycleWrapperState extends State<_LifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register this object as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);
    debugPrint('[SmartCalc] App started – lifecycle observer registered');
  }

  @override
  void dispose() {
    // Always deregister to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[SmartCalc] App disposed – lifecycle observer deregistered');
    super.dispose();
  }

  /// Called whenever the app's lifecycle state changes.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // App is in the foreground and interactive
        debugPrint('[SmartCalc] Lifecycle: resumed');
        break;
      case AppLifecycleState.inactive:
        // App is transitioning (e.g., phone call overlay)
        debugPrint('[SmartCalc] Lifecycle: inactive');
        break;
      case AppLifecycleState.paused:
        // App is in the background – a good time to save state if needed
        debugPrint('[SmartCalc] Lifecycle: paused');
        break;
      case AppLifecycleState.detached:
        // App process is being terminated
        debugPrint('[SmartCalc] Lifecycle: detached');
        break;
      case AppLifecycleState.hidden:
        // Multi-window: app is hidden but process still running
        debugPrint('[SmartCalc] Lifecycle: hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => const SmartCalcApp();
}
