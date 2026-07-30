import 'dart:convert';

/// Represents a single daily activity record, either from a dataset or sensor.
class ActivityRecord {
  final String id;
  final DateTime date;
  final int steps;
  final double caloriesBurned;
  final double distanceKm;
  final int activeMinutes;
  final int walkingMinutes;
  final int runningMinutes;
  final String workoutType;
  final double heartRateAvg;
  final double sleepHours;
  final bool isFromSensor; // true = sensor data, false = dataset

  const ActivityRecord({
    required this.id,
    required this.date,
    required this.steps,
    required this.caloriesBurned,
    required this.distanceKm,
    required this.activeMinutes,
    this.walkingMinutes = 0,
    this.runningMinutes = 0,
    this.workoutType = 'walking',
    this.heartRateAvg = 0.0,
    this.sleepHours = 0.0,
    this.isFromSensor = false,
  });

  ActivityRecord copyWith({
    String? id,
    DateTime? date,
    int? steps,
    double? caloriesBurned,
    double? distanceKm,
    int? activeMinutes,
    int? walkingMinutes,
    int? runningMinutes,
    String? workoutType,
    double? heartRateAvg,
    double? sleepHours,
    bool? isFromSensor,
  }) {
    return ActivityRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      distanceKm: distanceKm ?? this.distanceKm,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      walkingMinutes: walkingMinutes ?? this.walkingMinutes,
      runningMinutes: runningMinutes ?? this.runningMinutes,
      workoutType: workoutType ?? this.workoutType,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      sleepHours: sleepHours ?? this.sleepHours,
      isFromSensor: isFromSensor ?? this.isFromSensor,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'steps': steps,
        'caloriesBurned': caloriesBurned,
        'distanceKm': distanceKm,
        'activeMinutes': activeMinutes,
        'walkingMinutes': walkingMinutes,
        'runningMinutes': runningMinutes,
        'workoutType': workoutType,
        'heartRateAvg': heartRateAvg,
        'sleepHours': sleepHours,
        'isFromSensor': isFromSensor,
      };

  factory ActivityRecord.fromMap(Map<String, dynamic> map) => ActivityRecord(
        id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
        steps: (map['steps'] ?? 0).toInt(),
        caloriesBurned: (map['caloriesBurned'] ?? 0.0).toDouble(),
        distanceKm: (map['distanceKm'] ?? 0.0).toDouble(),
        activeMinutes: (map['activeMinutes'] ?? 0).toInt(),
        walkingMinutes: (map['walkingMinutes'] ?? 0).toInt(),
        runningMinutes: (map['runningMinutes'] ?? 0).toInt(),
        workoutType: map['workoutType'] ?? 'walking',
        heartRateAvg: (map['heartRateAvg'] ?? 0.0).toDouble(),
        sleepHours: (map['sleepHours'] ?? 0.0).toDouble(),
        isFromSensor: map['isFromSensor'] ?? false,
      );

  String toJson() => jsonEncode(toMap());
  factory ActivityRecord.fromJson(String source) =>
      ActivityRecord.fromMap(jsonDecode(source));
}
