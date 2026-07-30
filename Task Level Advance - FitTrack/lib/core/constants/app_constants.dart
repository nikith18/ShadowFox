/// App-wide constants used throughout FitTrack Pro.
/// Centralizing these values avoids magic numbers scattered across the codebase.
class AppConstants {
  AppConstants._();

  // App metadata
  static const String appName = 'FitTrack Pro';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Smart Fitness Tracking';

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyUserProfile = 'user_profile';
  static const String keyGoals = 'fitness_goals';
  static const String keyActivityHistory = 'activity_history';
  static const String keyDailyStats = 'daily_stats';
  static const String keySettings = 'app_settings';
  static const String keyStreakCount = 'streak_count';
  static const String keyLastActiveDate = 'last_active_date';
  static const String keyAchievements = 'achievements';

  // Default fitness targets
  static const int defaultDailyStepGoal = 8000;
  static const double defaultDailyCalorieGoal = 500.0;
  static const double defaultDailyDistanceGoal = 6.0;
  static const int defaultDailyActiveMinutes = 45;

  // Fitness calculation constants
  static const double stepsPerKm = 1312.0; // average steps per km
  static const double metWalking = 3.5; // MET value for walking
  static const double metRunning = 8.0; // MET value for running
  static const double metCycling = 6.0; // MET value for cycling

  // UI constants
  static const double borderRadius = 20.0;
  static const double cardElevation = 0.0;
  static const double glassOpacity = 0.15;
  static const double blurSigma = 12.0;

  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration longAnimation = Duration(milliseconds: 1000);
  static const Duration splashDuration = Duration(seconds: 3);

  // Chart colors (index maps to activity type)
  static const List<String> activityTypes = [
    'walking',
    'running',
    'cycling',
    'rest',
    'other'
  ];

  // Week days
  static const List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
}
