import 'package:flutter/foundation.dart';
import '../services/preference_service.dart';

/// Manages the application theme (dark / light mode) and persists the
/// user's choice using [PreferenceService].
///
/// Extends [ChangeNotifier] so [Provider] can efficiently notify only
/// the widgets that depend on theme state, avoiding unnecessary rebuilds
/// in unrelated subtrees.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  final PreferenceService _prefs;

  ThemeProvider({
    required PreferenceService preferenceService,
    required bool initialDarkMode,
  }) : _prefs = preferenceService,
       _isDarkMode = initialDarkMode;

  /// Whether the app is currently in dark mode.
  bool get isDarkMode => _isDarkMode;

  /// Toggles between dark and light mode, then persists the new value.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Triggers animated theme transition via AnimatedTheme
    await _prefs.saveDarkMode(_isDarkMode);
  }
}
