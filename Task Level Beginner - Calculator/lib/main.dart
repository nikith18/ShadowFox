import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app/app.dart';
import 'providers/calculator_provider.dart';
import 'providers/theme_provider.dart';
import 'services/calculator_service.dart';
import 'services/preference_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final PreferenceService prefs = await PreferenceService.getInstance();
  final bool savedDarkMode = prefs.getDarkMode();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(
            preferenceService: prefs,
            initialDarkMode: savedDarkMode,
          ),
        ),

        ChangeNotifierProvider<CalculatorProvider>(
          create: (_) =>
              CalculatorProvider(calculatorService: CalculatorService()),
        ),
      ],
      child: const _LifecycleWrapper(),
    ),
  );
}

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

    WidgetsBinding.instance.addObserver(this);
    debugPrint('[SmartCalc] App started - lifecycle observer registered');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint('[SmartCalc] App disposed - lifecycle observer deregistered');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        debugPrint('[SmartCalc] Lifecycle: resumed');
        break;
      case AppLifecycleState.inactive:
        debugPrint('[SmartCalc] Lifecycle: inactive');
        break;
      case AppLifecycleState.paused:
        debugPrint('[SmartCalc] Lifecycle: paused');
        break;
      case AppLifecycleState.detached:
        debugPrint('[SmartCalc] Lifecycle: detached');
        break;
      case AppLifecycleState.hidden:
        debugPrint('[SmartCalc] Lifecycle: hidden');
        break;
    }
  }

  @override
  Widget build(BuildContext context) => const SmartCalcApp();
}
