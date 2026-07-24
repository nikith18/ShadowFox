import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _kIsDarkMode = 'is_dark_mode';

  static PreferenceService? _instance;
  SharedPreferences? _prefs;

  PreferenceService._();

  static Future<PreferenceService> getInstance() async {
    _instance ??= PreferenceService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  Future<void> saveDarkMode(bool isDark) async {
    await _prefs?.setBool(_kIsDarkMode, isDark);
  }

  bool getDarkMode() {
    return _prefs?.getBool(_kIsDarkMode) ?? true;
  }
}
