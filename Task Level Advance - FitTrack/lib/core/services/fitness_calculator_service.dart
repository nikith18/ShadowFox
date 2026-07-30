import '../models/activity_record.dart';
import '../models/user_profile.dart';

/// Pure calculation helpers for fitness metrics.
/// Keeping these in a dedicated service ensures the math is testable and reusable.
class FitnessCalculatorService {
  FitnessCalculatorService._();

  // ─── Calorie Estimation ───────────────────────────────

  /// Estimates calories burned using a simplified MET formula.
  /// MET (Metabolic Equivalent of Task) × weight(kg) × duration(hours)
  static double estimateCalories({
    required double weightKg,
    required int durationMinutes,
    required String workoutType,
  }) {
    double met;
    switch (workoutType.toLowerCase()) {
      case 'running':
        met = 8.0;
        break;
      case 'cycling':
        met = 6.0;
        break;
      case 'rest':
        met = 1.2;
        break;
      default: // walking
        met = 3.5;
    }
    final hours = durationMinutes / 60.0;
    return met * weightKg * hours;
  }

  // ─── Distance Estimation ─────────────────────────────

  /// Converts steps to kilometers using average stride length.
  /// The typical adult takes ~1312 steps per kilometer.
  static double stepsToKilometers(int steps) {
    return steps / 1312.0;
  }

  // ─── Weekly Statistics ────────────────────────────────

  /// Returns average daily steps from a list of records.
  static double averageDailySteps(List<ActivityRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold<int>(0, (sum, r) => sum + r.steps);
    return total / records.length;
  }

  /// Returns average daily calories from a list of records.
  static double averageDailyCalories(List<ActivityRecord> records) {
    if (records.isEmpty) return 0;
    final total = records.fold<double>(0, (sum, r) => sum + r.caloriesBurned);
    return total / records.length;
  }

  /// Returns total distance in km from a list of records.
  static double totalDistance(List<ActivityRecord> records) {
    return records.fold(0.0, (sum, r) => sum + r.distanceKm);
  }

  /// Counts how many days in the list have steps > 0 (active days).
  static int activeDaysCount(List<ActivityRecord> records) {
    return records.where((r) => r.steps > 0 && r.workoutType != 'rest').length;
  }

  /// Calculates the current activity streak (consecutive active days).
  static int calculateStreak(List<ActivityRecord> records) {
    if (records.isEmpty) return 0;
    final sorted = List<ActivityRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));
    int streak = 0;
    DateTime? prevDate;
    for (final record in sorted) {
      if (record.workoutType == 'rest') continue;
      if (prevDate == null) {
        // Allow today or yesterday as the start of the streak
        final diff = DateTime.now().difference(record.date).inDays;
        if (diff > 1) break;
        prevDate = record.date;
        streak = 1;
      } else {
        final diff = prevDate.difference(record.date).inDays;
        if (diff == 1) {
          streak++;
          prevDate = record.date;
        } else {
          break;
        }
      }
    }
    return streak;
  }

  // ─── Goal Progress ───────────────────────────────────

  /// Calculates goal completion percentage from today's stats.
  static double goalCompletionPercent({
    required int currentSteps,
    required int goalSteps,
  }) {
    if (goalSteps == 0) return 0.0;
    return (currentSteps / goalSteps).clamp(0.0, 1.0);
  }

  // ─── BMI ─────────────────────────────────────────────

  static double calculateBmi(double heightCm, double weightKg) {
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  // ─── Personalised step-to-calorie ────────────────────

  /// A simple personalised calorie estimate based on user profile and steps.
  static double personalizedCaloriesFromSteps({
    required UserProfile profile,
    required int steps,
  }) {
    // Formula: steps × 0.04 × weight_factor
    final weightFactor = profile.weightKg / 70.0;
    return steps * 0.04 * weightFactor;
  }
}
