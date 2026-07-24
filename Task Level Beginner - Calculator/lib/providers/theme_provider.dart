import 'package:flutter/foundation.dart';
import '../services/preference_service.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;
  final PreferenceService _prefs;

  ThemeProvider({
    required PreferenceService preferenceService,
    required bool initialDarkMode,
  }) : _prefs = preferenceService,
       _isDarkMode = initialDarkMode;

  bool get isDarkMode => _isDarkMode;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _prefs.saveDarkMode(_isDarkMode);
  }
}
