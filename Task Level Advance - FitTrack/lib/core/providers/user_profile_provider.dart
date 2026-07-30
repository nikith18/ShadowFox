import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/local_storage_service.dart';

/// Manages the current user's profile data.
/// Exposes profile details to all widgets via Provider context.
class UserProfileProvider extends ChangeNotifier {
  UserProfile _profile;

  UserProfileProvider() : _profile = LocalStorageService.loadUserProfile();

  UserProfile get profile => _profile;

  Future<void> updateProfile(UserProfile updated) async {
    _profile = updated;
    await LocalStorageService.saveUserProfile(_profile);
    notifyListeners();
  }

  /// Updates only specific fields without replacing the entire profile.
  Future<void> updateField({
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
  }) async {
    _profile = _profile.copyWith(
      name: name,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      fitnessLevel: fitnessLevel,
      gender: gender,
      dailyStepGoal: dailyStepGoal,
      dailyCalorieGoal: dailyCalorieGoal,
      dailyDistanceGoal: dailyDistanceGoal,
      dailyActiveMinutesGoal: dailyActiveMinutesGoal,
    );
    await LocalStorageService.saveUserProfile(_profile);
    notifyListeners();
  }
}
