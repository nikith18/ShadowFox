import 'dart:convert';

/// Possible states of a fitness goal.
enum GoalStatus { active, completed, abandoned }

/// Supported goal types in FitTrack Pro.
/// Each type tracks a different metric.
enum GoalType { steps, calories, distance, activeMinutes, weeklyWorkouts }

/// A single user-defined fitness goal.
class FitnessGoal {
  final String id;
  final String title;
  final GoalType type;
  final double targetValue;
  double currentValue;
  final DateTime createdAt;
  DateTime? completedAt;
  GoalStatus status;
  final String? notes;

  FitnessGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetValue,
    this.currentValue = 0.0,
    required this.createdAt,
    this.completedAt,
    this.status = GoalStatus.active,
    this.notes,
  });

  /// Returns a 0.0–1.0 completion percentage clamped to [0,1].
  double get progressPercent => (currentValue / targetValue).clamp(0.0, 1.0);

  bool get isCompleted => status == GoalStatus.completed;

  String get unitLabel {
    switch (type) {
      case GoalType.steps:
        return 'steps';
      case GoalType.calories:
        return 'kcal';
      case GoalType.distance:
        return 'km';
      case GoalType.activeMinutes:
        return 'min';
      case GoalType.weeklyWorkouts:
        return 'workouts';
    }
  }

  String get typeIcon {
    switch (type) {
      case GoalType.steps:
        return '👣';
      case GoalType.calories:
        return '🔥';
      case GoalType.distance:
        return '📍';
      case GoalType.activeMinutes:
        return '⏱️';
      case GoalType.weeklyWorkouts:
        return '💪';
    }
  }

  FitnessGoal copyWith({
    String? id,
    String? title,
    GoalType? type,
    double? targetValue,
    double? currentValue,
    DateTime? createdAt,
    DateTime? completedAt,
    GoalStatus? status,
    String? notes,
  }) {
    return FitnessGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.index,
        'targetValue': targetValue,
        'currentValue': currentValue,
        'createdAt': createdAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'status': status.index,
        'notes': notes,
      };

  factory FitnessGoal.fromMap(Map<String, dynamic> map) => FitnessGoal(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        type: GoalType.values[map['type'] ?? 0],
        targetValue: (map['targetValue'] ?? 0.0).toDouble(),
        currentValue: (map['currentValue'] ?? 0.0).toDouble(),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        completedAt: map['completedAt'] != null
            ? DateTime.tryParse(map['completedAt'])
            : null,
        status: GoalStatus.values[map['status'] ?? 0],
        notes: map['notes'],
      );

  String toJson() => jsonEncode(toMap());
  factory FitnessGoal.fromJson(String source) =>
      FitnessGoal.fromMap(jsonDecode(source));
}
