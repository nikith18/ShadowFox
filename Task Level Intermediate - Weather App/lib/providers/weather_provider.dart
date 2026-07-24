import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/location_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

enum WeatherStatus { initial, locating, loading, refreshing, loaded, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  ForecastModel? _forecast;
  String? _errorMessage;
  WeatherErrorType? _errorType;

  bool _isOfflineData = false;
  DateTime? _lastUpdated;

  int _searchSessionId = 0;
  int _fetchSessionId = 0;

  List<LocationResult> _searchResults = [];
  bool _isSearching = false;

  double? _lastLat;
  double? _lastLon;
  String _lastCityName = '';
  String _lastAdminArea = '';
  String _lastCountry = '';
  bool _lastWasGps = false;

  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  ForecastModel? get forecast => _forecast;
  String? get errorMessage => _errorMessage;
  WeatherErrorType? get errorType => _errorType;
  bool get hasData => _weather != null;
  List<LocationResult> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  bool get isOfflineData => _isOfflineData;
  DateTime? get lastUpdated => _lastUpdated;

  WeatherProvider() {
    _initCache();
  }

  Future<void> _initCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedWeather = prefs.getString('cached_weather');
    final cachedCity = prefs.getString('cached_city');
    final cachedAdmin = prefs.getString('cached_admin');
    final cachedCountry = prefs.getString('cached_country');
    final lastUpdateTimestamp = prefs.getInt('cached_time');

    if (cachedWeather != null &&
        cachedCity != null &&
        lastUpdateTimestamp != null) {
      try {
        final json = jsonDecode(cachedWeather) as Map<String, dynamic>;
        _weather = WeatherModel.fromOpenMeteo(
          json,
          cityName: cachedCity,
          adminArea: cachedAdmin ?? '',
          country: cachedCountry ?? '',
          latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
          longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
        );
        _forecast = ForecastModel.fromOpenMeteo(json);
        _lastUpdated = DateTime.fromMillisecondsSinceEpoch(lastUpdateTimestamp);
        _isOfflineData = true;
        _status = WeatherStatus.loaded;
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<void> _saveToCache(
    Map<String, dynamic> rawJson,
    String city,
    String admin,
    String country,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString('cached_weather', jsonEncode(rawJson));
    await prefs.setString('cached_city', city);
    await prefs.setString('cached_admin', admin);
    await prefs.setString('cached_country', country);
    await prefs.setInt('cached_time', now.millisecondsSinceEpoch);
    _lastUpdated = now;
    _isOfflineData = false;
  }

  Future<void> searchPlaces(String query) async {
    final sessionId = ++_searchSessionId;

    if (query.trim().isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    try {
      final results = await _locationService.searchPlaces(query);
      if (sessionId == _searchSessionId) {
        _searchResults = results;
      }
    } catch (_) {
      if (sessionId == _searchSessionId) {
        _searchResults = [];
      }
    } finally {
      if (sessionId == _searchSessionId) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchSessionId++;
    _searchResults = [];
    _isSearching = false;
    notifyListeners();
  }

  Future<void> selectLocation(LocationResult location) async {
    _searchResults = [];
    _lastWasGps = false;
    _lastLat = location.latitude;
    _lastLon = location.longitude;
    _lastCityName = location.name;
    _lastAdminArea = location.adminArea ?? '';
    _lastCountry = location.country;
    await _fetchByCoords(
      location.latitude,
      location.longitude,
      cityName: location.name,
      adminArea: location.adminArea ?? '',
      country: location.country,
    );
  }

  Future<void> fetchByLocation() async {
    final sessionId = ++_fetchSessionId;

    if (_weather != null) {
      _status = WeatherStatus.refreshing;
    } else {
      _status = WeatherStatus.locating;
    }
    _errorMessage = null;
    _errorType = null;
    _searchResults = [];
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();

      if (sessionId != _fetchSessionId) return;

      String city = 'Current Location';
      String state = '';
      String country = '';

      final rev = await _locationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (sessionId != _fetchSessionId) return;

      if (rev != null) {
        city = rev.name;
        state = rev.adminArea ?? '';
        country = rev.country;
      }

      _lastWasGps = true;
      _lastLat = position.latitude;
      _lastLon = position.longitude;
      _lastCityName = city;
      _lastAdminArea = state;
      _lastCountry = country;

      await _fetchByCoords(
        position.latitude,
        position.longitude,
        cityName: city,
        adminArea: state,
        country: country,
        sessionId: sessionId,
        reusingLoadingState: true,
      );
    } on LocationException catch (e) {
      if (sessionId == _fetchSessionId) {
        _setError(e.message, _mapLocationError(e.type));
      }
    } catch (_) {
      if (sessionId == _fetchSessionId) {
        _setError(
          'Could not retrieve your location. Please search for a city.',
          WeatherErrorType.unknown,
        );
      }
    }
  }

  Future<void> retry() async {
    if (_lastWasGps) {
      await fetchByLocation();
    } else if (_lastLat != null && _lastLon != null) {
      await _fetchByCoords(
        _lastLat!,
        _lastLon!,
        cityName: _lastCityName,
        adminArea: _lastAdminArea,
        country: _lastCountry,
        isRefresh: true,
      );
    }
  }

  Future<void> _fetchByCoords(
    double lat,
    double lon, {
    required String cityName,
    required String adminArea,
    required String country,
    int? sessionId,
    bool reusingLoadingState = false,
    bool isRefresh = false,
  }) async {
    final currentSession = sessionId ?? ++_fetchSessionId;

    if (!reusingLoadingState) {
      _status = (_weather != null || isRefresh)
          ? WeatherStatus.refreshing
          : WeatherStatus.loading;
      _errorMessage = null;
      _errorType = null;
      notifyListeners();
    }

    try {
      final result = await _weatherService.fetchByCoords(
        lat,
        lon,
        cityName: cityName,
        adminArea: adminArea,
        country: country,
      );

      if (currentSession != _fetchSessionId) return;

      _weather = result.weather;
      _forecast = result.forecast;
      _status = WeatherStatus.loaded;

      await _saveToCache(result.rawJson, cityName, adminArea, country);

      notifyListeners();
    } on WeatherException catch (e) {
      if (currentSession != _fetchSessionId) return;
      if (_weather != null) {
        _isOfflineData = true;
        _status = WeatherStatus.loaded;
        notifyListeners();
      } else {
        _setError(e.message, e.type);
      }
    } catch (_) {
      if (currentSession != _fetchSessionId) return;
      if (_weather != null) {
        _isOfflineData = true;
        _status = WeatherStatus.loaded;
        notifyListeners();
      } else {
        _setError(
          'An unexpected error occurred. Please try again.',
          WeatherErrorType.unknown,
        );
      }
    }
  }

  void _setError(String message, WeatherErrorType type) {
    _status = WeatherStatus.error;
    _errorMessage = message;
    _errorType = type;
    notifyListeners();
  }

  WeatherErrorType _mapLocationError(LocationErrorType type) {
    return switch (type) {
      LocationErrorType.timeout => WeatherErrorType.timeout,
      _ => WeatherErrorType.locationError,
    };
  }
}
