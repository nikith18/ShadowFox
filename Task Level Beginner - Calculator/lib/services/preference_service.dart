import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for persisting and retrieving user preferences.
/// Wraps SharedPreferences with a typed API so callers never deal
/// with raw string keys or type casting.
class PreferenceService {
  // ──────────────────────────────────────────────
  //  KEYS
  // ──────────────────────────────────────────────

  static const String _kIsDarkMode = 'is_dark_mode';

  // ──────────────────────────────────────────────
  //  SINGLETON
  // ──────────────────────────────────────────────

  static PreferenceService? _instance;
  SharedPreferences? _prefs;

  PreferenceService._();

  /// Returns the singleton instance, initialising SharedPreferences lazily.
  static Future<PreferenceService> getInstance() async {
    _instance ??= PreferenceService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // ──────────────────────────────────────────────
  //  THEME PREFERENCE
  // ──────────────────────────────────────────────

  /// Persists the dark-mode preference.
  Future<void> saveDarkMode(bool isDark) async {
    await _prefs?.setBool(_kIsDarkMode, isDark);
  }

  /// Retrieves the persisted dark-mode preference.
  /// Defaults to [true] (dark mode) on first launch.
  bool getDarkMode() {
    return _prefs?.getBool(_kIsDarkMode) ?? true;
  }
}
