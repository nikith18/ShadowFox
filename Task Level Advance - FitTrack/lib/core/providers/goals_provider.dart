import 'package:flutter/material.dart';
import '../models/fitness_goal.dart';
import '../services/local_storage_service.dart';

/// Manages the full lifecycle of fitness goals: adding, editing, deleting, and tracking.
class GoalsProvider extends ChangeNotifier {
  List<FitnessGoal> _goals = [];

  GoalsProvider() {
    _goals = LocalStorageService.loadGoals();
  }

  List<FitnessGoal> get allGoals => List.unmodifiable(_goals);
  List<FitnessGoal> get activeGoals =>
      _goals.where((g) => g.status == GoalStatus.active).toList();
  List<FitnessGoal> get completedGoals =>
      _goals.where((g) => g.status == GoalStatus.completed).toList();

  Future<void> addGoal(FitnessGoal goal) async {
    _goals.add(goal);
    await _save();
  }

  Future<void> updateGoal(FitnessGoal updated) async {
    final index = _goals.indexWhere((g) => g.id == updated.id);
    if (index == -1) return;
    _goals[index] = updated;
    await _save();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _save();
  }

  Future<void> markComplete(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    _goals[index] = _goals[index].copyWith(
      status: GoalStatus.completed,
      completedAt: DateTime.now(),
      currentValue: _goals[index].targetValue,
    );
    await _save();
  }

  /// Updates a goal's currentValue by adding a delta (e.g., today's steps).
  Future<void> addProgress(String id, double delta) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;
    final goal = _goals[index];
    final newValue =
        (goal.currentValue + delta).clamp(0.0, goal.targetValue * 2);
    final isNowComplete = newValue >= goal.targetValue;
    _goals[index] = goal.copyWith(
      currentValue: newValue,
      status: isNowComplete ? GoalStatus.completed : GoalStatus.active,
      completedAt: isNowComplete ? DateTime.now() : goal.completedAt,
    );
    await _save();
  }

  Future<void> _save() async {
    await LocalStorageService.saveGoals(_goals);
    notifyListeners();
  }
}
