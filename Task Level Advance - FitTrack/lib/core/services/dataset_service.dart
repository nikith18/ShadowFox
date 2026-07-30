import 'dart:async';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import '../models/activity_record.dart';

/// Parses fitness dataset files (CSV/JSON) into ActivityRecord lists.
/// Processing happens on a Dart isolate-friendly async path to keep the UI smooth.
class DatasetService {
  DatasetService._();

  /// Loads the bundled CSV dataset from assets and returns parsed records.
  /// Returns an empty list if the file is missing or malformed – never throws.
  static Future<List<ActivityRecord>> loadFromAssets() async {
    try {
      final raw = await rootBundle.loadString('assets/data/fitness_data.csv');
      return _parseCsv(raw);
    } catch (e) {
      return [];
    }
  }

  /// Parses a raw CSV string.
  /// Handles missing columns by providing safe defaults.
  static List<ActivityRecord> _parseCsv(String raw) {
    List<ActivityRecord> records = [];
    try {
      final rows = const CsvToListConverter(eol: '\n').convert(raw);
      if (rows.length < 2) return records;

      // First row is the header
      final header =
          rows[0].map((h) => h.toString().trim().toLowerCase()).toList();

      // Build a lookup map from column name to index for safe access
      final idx = {for (var i = 0; i < header.length; i++) header[i]: i};

      T safeGet<T>(List row, String col, T defaultVal) {
        final i = idx[col];
        if (i == null || i >= row.length) return defaultVal;
        final val = row[i];
        if (val == null || val.toString().isEmpty) return defaultVal;
        try {
          if (T == int) return int.parse(val.toString()) as T;
          if (T == double) return double.parse(val.toString()) as T;
          return val.toString() as T;
        } catch (_) {
          return defaultVal;
        }
      }

      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty) continue;

        try {
          final dateStr = safeGet<String>(row, 'date', '');
          final date = DateTime.tryParse(dateStr) ??
              DateTime.now().subtract(Duration(days: rows.length - i));

          final steps = safeGet<int>(row, 'steps', 0);
          final calories = safeGet<double>(row, 'calories', 0.0);
          final distanceKm = safeGet<double>(row, 'distance_km', 0.0);
          final activeMinutes = safeGet<int>(row, 'active_minutes', 0);
          final heartRate = safeGet<double>(row, 'heart_rate_avg', 0.0);
          final sleepHours = safeGet<double>(row, 'sleep_hours', 0.0);
          final workoutType = safeGet<String>(row, 'workout_type', 'walking');

          records.add(ActivityRecord(
            id: 'dataset_$i',
            date: date,
            steps: steps,
            caloriesBurned: calories,
            distanceKm: distanceKm,
            activeMinutes: activeMinutes,
            walkingMinutes: workoutType == 'walking' ? activeMinutes : 0,
            runningMinutes: workoutType == 'running' ? activeMinutes : 0,
            workoutType: workoutType,
            heartRateAvg: heartRate,
            sleepHours: sleepHours,
            isFromSensor: false,
          ));
        } catch (_) {
          // Skip malformed rows; the rest of the dataset is still valid
          continue;
        }
      }
    } catch (e) {
      return [];
    }
    return records;
  }
}
