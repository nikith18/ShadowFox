import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

/// Manages app-wide settings: units, notifications, sensor toggle, etc.
class SettingsProvider extends ChangeNotifier {
  bool _useKilometers = true;
  bool _notificationsEnabled = true;
  bool _sensorEnabled = false;
  bool _datasetEnabled = true;

  SettingsProvider() {
    _loadSettings();
  }

  bool get useKilometers => _useKilometers;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get sensorEnabled => _sensorEnabled;
  bool get datasetEnabled => _datasetEnabled;

  String get distanceUnit => _useKilometers ? 'km' : 'mi';

  double convertDistance(double km) => _useKilometers ? km : km * 0.621371;

  void _loadSettings() {
    final settings = LocalStorageService.loadSettings();
    _useKilometers = settings['useKilometers'] ?? true;
    _notificationsEnabled = settings['notificationsEnabled'] ?? true;
    _sensorEnabled = settings['sensorEnabled'] ?? false;
    _datasetEnabled = settings['datasetEnabled'] ?? true;
  }

  Future<void> _save() async {
    await LocalStorageService.saveSettings({
      'useKilometers': _useKilometers,
      'notificationsEnabled': _notificationsEnabled,
      'sensorEnabled': _sensorEnabled,
      'datasetEnabled': _datasetEnabled,
    });
    notifyListeners();
  }

  Future<void> setUseKilometers(bool value) async {
    _useKilometers = value;
    await _save();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _save();
  }

  Future<void> setSensorEnabled(bool value) async {
    _sensorEnabled = value;
    await _save();
  }

  Future<void> setDatasetEnabled(bool value) async {
    _datasetEnabled = value;
    await _save();
  }
}
