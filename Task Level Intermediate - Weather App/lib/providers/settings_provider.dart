import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _fahrenheitKey = 'settings_is_fahrenheit';
  static const String _reduceMotionKey = 'settings_reduce_motion';

  bool _isFahrenheit = false;
  bool _reduceMotion = false;
  bool _isInitialized = false;

  bool get isFahrenheit => _isFahrenheit;
  bool get reduceMotion => _reduceMotion;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFahrenheit = prefs.getBool(_fahrenheitKey) ?? false;
      _reduceMotion = prefs.getBool(_reduceMotionKey) ?? false;
    } catch (_) {
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> toggleUnit() async {
    _isFahrenheit = !_isFahrenheit;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_fahrenheitKey, _isFahrenheit);
    } catch (_) {}
  }

  Future<void> toggleMotion() async {
    _reduceMotion = !_reduceMotion;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_reduceMotionKey, _reduceMotion);
    } catch (_) {}
  }
}
