import 'dart:async';
import 'package:flutter/material.dart';
import '../models/activity_record.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';
import '../services/dataset_service.dart';
import '../services/fitness_calculator_service.dart';

/// Central provider for all activity-related state.
/// Manages both the live/sensor "today" stats and the full history list.
class ActivityProvider extends ChangeNotifier {
  List<ActivityRecord> _history = [];
  ActivityRecord? _todayRecord;
  bool _isLoading = false;
  String? _error;
  bool _useSensorMode = false;

  // Live tracking state (used in sensor mode)
  int _liveSteps = 0;
  double _liveCalories = 0.0;
  double _liveDistanceKm = 0.0;
  int _liveActiveMinutes = 0;
  int _streakCount = 0;

  ActivityProvider() {
    _init();
  }

  // ─── Getters ──────────────────────────────────────────

  List<ActivityRecord> get history => List.unmodifiable(_history);
  ActivityRecord? get todayRecord => _todayRecord;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get useSensorMode => _useSensorMode;

  int get todaySteps =>
      _useSensorMode ? _liveSteps : (_todayRecord?.steps ?? 0);
  double get todayCalories =>
      _useSensorMode ? _liveCalories : (_todayRecord?.caloriesBurned ?? 0.0);
  double get todayDistanceKm =>
      _useSensorMode ? _liveDistanceKm : (_todayRecord?.distanceKm ?? 0.0);
  int get todayActiveMinutes =>
      _useSensorMode ? _liveActiveMinutes : (_todayRecord?.activeMinutes ?? 0);
  int get streakCount => _streakCount;

  /// Returns the last 7 days of activity records in chronological order.
  List<ActivityRecord> get last7Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final list = _history.where((r) => r.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// Returns the last 30 days similarly.
  List<ActivityRecord> get last30Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return _history.where((r) => r.date.isAfter(cutoff)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  double get averageDailySteps =>
      FitnessCalculatorService.averageDailySteps(_history);
  double get averageDailyCalories =>
      FitnessCalculatorService.averageDailyCalories(_history);
  double get totalDistanceKm =>
      FitnessCalculatorService.totalDistance(_history);
  int get activeDaysCount => FitnessCalculatorService.activeDaysCount(_history);

  // ─── Initialization ───────────────────────────────────

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = LocalStorageService.loadActivityHistory();
      _streakCount = LocalStorageService.loadStreakCount();

      // If history is empty, auto-load the bundled dataset to give a rich first-run experience
      if (_history.isEmpty) {
        await loadDataset();
      } else {
        _findTodayRecord();
      }
    } catch (e) {
      _error = 'Failed to load activity data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Dataset Mode ─────────────────────────────────────

  Future<void> loadDataset() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final records = await DatasetService.loadFromAssets();
      if (records.isNotEmpty) {
        _history = records;
        await LocalStorageService.saveActivityHistory(_history);
        _findTodayRecord();
        _recalculateStreak();
      }
    } catch (e) {
      _error = 'Failed to load dataset: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── History Management ───────────────────────────────

  Future<void> addRecord(ActivityRecord record) async {
    _history.removeWhere((r) => _isSameDay(r.date, record.date));
    _history.add(record);
    _history.sort((a, b) => b.date.compareTo(a.date));
    _findTodayRecord();
    _recalculateStreak();
    await LocalStorageService.saveActivityHistory(_history);
    notifyListeners();
  }

  Future<void> deleteRecord(String id) async {
    _history.removeWhere((r) => r.id == id);
    _findTodayRecord();
    _recalculateStreak();
    await LocalStorageService.saveActivityHistory(_history);
    notifyListeners();
  }

  // ─── Sensor Mode ─────────────────────────────────────

  void setSensorMode(bool value) {
    _useSensorMode = value;
    notifyListeners();
  }

  void updateLiveStats({
    int? steps,
    double? calories,
    double? distanceKm,
    int? activeMinutes,
    UserProfile? profile,
  }) {
    if (steps != null) {
      _liveSteps = steps;
      // Derive calories and distance from steps if not provided
      if (profile != null) {
        _liveCalories = FitnessCalculatorService.personalizedCaloriesFromSteps(
            profile: profile, steps: steps);
      }
      _liveDistanceKm = FitnessCalculatorService.stepsToKilometers(steps);
    }
    if (calories != null) _liveCalories = calories;
    if (distanceKm != null) _liveDistanceKm = distanceKm;
    if (activeMinutes != null) _liveActiveMinutes = activeMinutes;
    notifyListeners();
  }

  // ─── Helpers ─────────────────────────────────────────

  void _findTodayRecord() {
    final today = DateTime.now();
    _todayRecord = _history.cast<ActivityRecord?>().firstWhere(
          (r) => _isSameDay(r!.date, today),
          orElse: () => null,
        );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _recalculateStreak() {
    _streakCount = FitnessCalculatorService.calculateStreak(_history);
    final lastDate = _history.isNotEmpty ? _history.first.date : DateTime.now();
    LocalStorageService.saveStreak(_streakCount, lastDate);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
