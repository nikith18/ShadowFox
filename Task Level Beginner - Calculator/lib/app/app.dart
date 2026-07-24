import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../app/theme/app_theme.dart';
import '../screens/calculator_screen.dart';

/// Root application widget.
///
/// Wraps [MaterialApp] inside [AnimatedTheme] so that switching between
/// dark and light modes plays a smooth colour-interpolation animation.
///
/// [Consumer<ThemeProvider>] rebuilds ONLY this widget subtree when the
/// theme changes – the rest of the widget tree is unaffected.
class SmartCalcApp extends StatelessWidget {
  const SmartCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Smart Modern Calculator',
          debugShowCheckedModeBanner: false,

          // theme and darkTheme are used together with themeMode
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,

          // AnimatedTheme is provided by MaterialApp automatically
          // via themeAnimationDuration / themeAnimationCurve
          themeAnimationDuration: const Duration(milliseconds: 400),
          themeAnimationCurve: Curves.easeInOut,

          home: const CalculatorScreen(),
        );
      },
    );
  }
}
