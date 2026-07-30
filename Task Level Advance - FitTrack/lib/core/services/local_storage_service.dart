import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/fitness_goal.dart';
import '../models/activity_record.dart';
import '../constants/app_constants.dart';

/// Service responsible for reading and writing all app data to local storage.
/// Uses SharedPreferences for persistence. This is the single source of truth
/// for data that must survive app restarts.
class LocalStorageService {
  static SharedPreferences? _prefs;

  /// Must be called once at app startup (in main.dart) before any data is read.
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) throw Exception('LocalStorageService not initialized!');
    return _prefs!;
  }

  // ───────────────────── Theme ─────────────────────

  static Future<void> saveThemeMode(bool isDark) async {
    await _instance.setBool(AppConstants.keyThemeMode, isDark);
  }

  static bool loadThemeMode() {
    return _instance.getBool(AppConstants.keyThemeMode) ?? true;
  }

  // ─────────────────── User Profile ────────────────

  static Future<void> saveUserProfile(UserProfile profile) async {
    await _instance.setString(AppConstants.keyUserProfile, profile.toJson());
  }

  static UserProfile loadUserProfile() {
    final json = _instance.getString(AppConstants.keyUserProfile);
    if (json == null) return UserProfile.defaults();
    try {
      return UserProfile.fromJson(json);
    } catch (_) {
      return UserProfile.defaults();
    }
  }

  // ─────────────────── Fitness Goals ───────────────

  static Future<void> saveGoals(List<FitnessGoal> goals) async {
    final list = goals.map((g) => jsonEncode(g.toMap())).toList();
    await _instance.setStringList(AppConstants.keyGoals, list);
  }

  static List<FitnessGoal> loadGoals() {
    final list = _instance.getStringList(AppConstants.keyGoals) ?? [];
    return list
        .map((s) {
          try {
            return FitnessGoal.fromMap(jsonDecode(s));
          } catch (_) {
            return null;
          }
        })
        .whereType<FitnessGoal>()
        .toList();
  }

  // ──────────────────── Activity History ───────────

  static Future<void> saveActivityHistory(List<ActivityRecord> records) async {
    final list = records.map((r) => jsonEncode(r.toMap())).toList();
    await _instance.setStringList(AppConstants.keyActivityHistory, list);
  }

  static List<ActivityRecord> loadActivityHistory() {
    final list = _instance.getStringList(AppConstants.keyActivityHistory) ?? [];
    return list
        .map((s) {
          try {
            return ActivityRecord.fromMap(jsonDecode(s));
          } catch (_) {
            return null;
          }
        })
        .whereType<ActivityRecord>()
        .toList();
  }

  // ─────────────────── Settings ────────────────────

  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _instance.setString(AppConstants.keySettings, jsonEncode(settings));
  }

  static Map<String, dynamic> loadSettings() {
    final json = _instance.getString(AppConstants.keySettings);
    if (json == null) return {};
    try {
      return jsonDecode(json) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  // ─────────────────── Streak ──────────────────────

  static Future<void> saveStreak(int count, DateTime lastDate) async {
    await _instance.setInt(AppConstants.keyStreakCount, count);
    await _instance.setString(
        AppConstants.keyLastActiveDate, lastDate.toIso8601String());
  }

  static int loadStreakCount() {
    return _instance.getInt(AppConstants.keyStreakCount) ?? 0;
  }

  static DateTime? loadLastActiveDate() {
    final s = _instance.getString(AppConstants.keyLastActiveDate);
    if (s == null) return null;
    return DateTime.tryParse(s);
  }

  // ─────────────────── Utilities ───────────────────

  static Future<void> clearAll() async {
    await _instance.clear();
  }
}
