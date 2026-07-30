import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

/// Manages the app-wide theme (dark / light).
/// Persists the user's preference so it survives hot restarts.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode;

  ThemeProvider() : _isDarkMode = LocalStorageService.loadThemeMode();

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await LocalStorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    await LocalStorageService.saveThemeMode(_isDarkMode);
    notifyListeners();
  }
}
