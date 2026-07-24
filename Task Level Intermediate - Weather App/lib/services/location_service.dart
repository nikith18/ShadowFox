import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../utils/constants.dart';


enum LocationErrorType {
  permissionDenied,
  permissionPermanentlyDenied,
  serviceDisabled,
  unavailable,
  timeout,
  unsupported,
}

class LocationException implements Exception {
  final String message;
  final LocationErrorType type;
  const LocationException(this.message, this.type);

  @override
  String toString() => 'LocationException(${type.name}): $message';
}


class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      throw const LocationException(
        'Location services are not supported on this device.\nSearch for a city to load weather.',
        LocationErrorType.unsupported,
      );
    }

    if (!serviceEnabled) {
      throw const LocationException(
        'Location services are disabled. Please enable GPS and try again.',
        LocationErrorType.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          'Location permission denied. Search for a city to load weather.',
          LocationErrorType.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is permanently denied.\nPlease enable it in App Settings → Permissions.',
        LocationErrorType.permissionPermanentlyDenied,
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
    } on TimeoutException {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException(
        'Location request timed out. Please try again.',
        LocationErrorType.timeout,
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException(
        'Could not determine your location. Please try again or search for a city.',
        LocationErrorType.unavailable,
      );
    }
  }

  Future<List<LocationResult>> searchPlaces(
    String query, {
    int count = 10,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final uri = Uri.parse(kGeocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmed,
        'count': count.toString(),
        'language': 'en',
        'format': 'json',
      },
    );

    try {
      final response = await http.get(uri).timeout(kRequestTimeout);
      if (response.statusCode != 200) return [];
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List?;
      if (results == null || results.isEmpty) return [];
      return results
          .map((e) => LocationResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      return [];
    } on TimeoutException {
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<LocationResult?> reverseGeocode(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$lat&longitude=$lon&localityLanguage=en',
    );

    try {
      final response = await http.get(uri).timeout(kRequestTimeout);
      if (response.statusCode != 200) return null;
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      String city =
          json['city'] as String? ?? json['locality'] as String? ?? '';
      if (city.isEmpty) {
        city = json['principalSubdivision'] as String? ?? 'Unknown Location';
      }

      final state = json['principalSubdivision'] as String? ?? '';
      final country = json['countryName'] as String? ?? '';
      final countryCode = json['countryCode'] as String? ?? '';

      return LocationResult(
        name: city,
        latitude: lat,
        longitude: lon,
        country: country,
        countryCode: countryCode,
        adminArea: state,
      );
    } catch (_) {
      return null;
    }
  }
}
