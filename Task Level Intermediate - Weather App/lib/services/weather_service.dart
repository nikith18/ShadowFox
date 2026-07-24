import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../utils/constants.dart';


enum WeatherErrorType {
  noInternet,
  timeout,
  serverError,
  parseError,
  locationNotFound,
  noResults,
  locationError,
  unknown,
}

class WeatherException implements Exception {
  final String message;
  final WeatherErrorType type;
  const WeatherException(this.message, this.type);

  @override
  String toString() => 'WeatherException(${type.name}): $message';
}

class WeatherResult {
  final WeatherModel weather;
  final ForecastModel forecast;
  final Map<String, dynamic> rawJson;

  WeatherResult({
    required this.weather,
    required this.forecast,
    required this.rawJson,
  });
}


class WeatherService {
  Future<WeatherResult> fetchByCoords(
    double latitude,
    double longitude, {
    required String cityName,
    required String adminArea,
    required String country,
  }) async {
    final uri = Uri.parse(kForecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current': [
          'temperature_2m',
          'apparent_temperature',
          'relative_humidity_2m',
          'weather_code',
          'surface_pressure',
          'wind_speed_10m',
          'wind_direction_10m',
        ].join(','),
        'hourly': [
          'temperature_2m',
          'apparent_temperature',
          'weather_code',
          'precipitation_probability',
          'precipitation',
          'visibility',
        ].join(','),
        'daily': [
          'weather_code',
          'temperature_2m_max',
          'temperature_2m_min',
          'sunrise',
          'sunset',
          'precipitation_probability_max',
        ].join(','),
        'timezone': 'auto',
        'forecast_days': '7',
      },
    );

    final response = await _get(uri);
    _checkStatus(response);

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final weather = WeatherModel.fromOpenMeteo(
        json,
        cityName: cityName,
        adminArea: adminArea,
        country: country,
        latitude: latitude,
        longitude: longitude,
      );
      final forecast = ForecastModel.fromOpenMeteo(json);
      return WeatherResult(weather: weather, forecast: forecast, rawJson: json);
    } catch (e) {
      throw WeatherException(
        'Failed to parse weather data. Please try again.',
        WeatherErrorType.parseError,
      );
    }
  }


  Future<http.Response> _get(Uri uri) async {
    try {
      return await http.get(uri).timeout(kRequestTimeout);
    } on SocketException {
      throw const WeatherException(
        'No internet connection. Please check your network.',
        WeatherErrorType.noInternet,
      );
    } on HttpException {
      throw const WeatherException(
        'Network error occurred. Please try again.',
        WeatherErrorType.noInternet,
      );
    } on TimeoutException {
      throw const WeatherException(
        'Request timed out. Please try again.',
        WeatherErrorType.timeout,
      );
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('TimeoutException') || msg.contains('timeout')) {
        throw const WeatherException(
          'Request timed out. Please try again.',
          WeatherErrorType.timeout,
        );
      }
      throw const WeatherException(
        'An unexpected error occurred. Please try again.',
        WeatherErrorType.unknown,
      );
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 200) return;
    throw WeatherException(
      'Weather service error (${response.statusCode}). Please try again.',
      WeatherErrorType.serverError,
    );
  }
}
