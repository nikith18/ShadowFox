import 'dart:convert';

/// Model representing a user's fitness profile.
/// Stored in SharedPreferences as JSON so it persists across sessions.
class UserProfile {
  final String name;
  final int age;
  final double heightCm;
  final double weightKg;
  final String fitnessLevel; // beginner, intermediate, advanced
  final String gender;
  final int dailyStepGoal;
  final double dailyCalorieGoal;
  final double dailyDistanceGoal;
  final int dailyActiveMinutesGoal;

  const UserProfile({
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    this.fitnessLevel = 'beginner',
    this.gender = 'not specified',
    this.dailyStepGoal = 8000,
    this.dailyCalorieGoal = 500.0,
    this.dailyDistanceGoal = 6.0,
    this.dailyActiveMinutesGoal = 45,
  });

  /// Calculates BMI from height (cm) and weight (kg).
  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  /// Returns a human-readable BMI category.
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? heightCm,
    double? weightKg,
    String? fitnessLevel,
    String? gender,
    int? dailyStepGoal,
    double? dailyCalorieGoal,
    double? dailyDistanceGoal,
    int? dailyActiveMinutesGoal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      gender: gender ?? this.gender,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyDistanceGoal: dailyDistanceGoal ?? this.dailyDistanceGoal,
      dailyActiveMinutesGoal:
          dailyActiveMinutesGoal ?? this.dailyActiveMinutesGoal,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'age': age,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'fitnessLevel': fitnessLevel,
        'gender': gender,
        'dailyStepGoal': dailyStepGoal,
        'dailyCalorieGoal': dailyCalorieGoal,
        'dailyDistanceGoal': dailyDistanceGoal,
        'dailyActiveMinutesGoal': dailyActiveMinutesGoal,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        name: map['name'] ?? 'Fitness User',
        age: map['age'] ?? 25,
        heightCm: (map['heightCm'] ?? 170.0).toDouble(),
        weightKg: (map['weightKg'] ?? 70.0).toDouble(),
        fitnessLevel: map['fitnessLevel'] ?? 'beginner',
        gender: map['gender'] ?? 'not specified',
        dailyStepGoal: map['dailyStepGoal'] ?? 8000,
        dailyCalorieGoal: (map['dailyCalorieGoal'] ?? 500.0).toDouble(),
        dailyDistanceGoal: (map['dailyDistanceGoal'] ?? 6.0).toDouble(),
        dailyActiveMinutesGoal: map['dailyActiveMinutesGoal'] ?? 45,
      );

  String toJson() => jsonEncode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(jsonDecode(source));

  /// Default profile used on first launch.
  factory UserProfile.defaults() => const UserProfile(
        name: 'Fitness User',
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
      );
}
