class WeatherModel {
  final String cityName;
  final String adminArea;
  final String country;
  final double latitude;
  final double longitude;

  final double temperature;
  final double feelsLike;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double? visibility;

  final double tempMin;
  final double tempMax;

  final String sunrise;
  final String sunset;
  final int utcOffsetSeconds;

  const WeatherModel({
    required this.cityName,
    required this.adminArea,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    this.visibility,
    required this.tempMin,
    required this.tempMax,
    required this.sunrise,
    required this.sunset,
    required this.utcOffsetSeconds,
  });

  factory WeatherModel.fromOpenMeteo(
    Map<String, dynamic> json, {
    required String cityName,
    required String adminArea,
    required String country,
    required double latitude,
    required double longitude,
  }) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    double? vis;
    if (json['hourly'] != null && json['hourly']['visibility'] != null) {
      final visList = json['hourly']['visibility'] as List;
      if (visList.isNotEmpty) {
        vis = (visList[0] as num?)?.toDouble();
      }
    }

    final sunrises = daily['sunrise'] as List;
    final sunsets = daily['sunset'] as List;
    final tempMins = daily['temperature_2m_min'] as List;
    final tempMaxs = daily['temperature_2m_max'] as List;

    return WeatherModel(
      cityName: cityName,
      adminArea: adminArea,
      country: country,
      latitude: latitude,
      longitude: longitude,
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).toInt(),
      weatherCode: (current['weather_code'] as num).toInt(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windDirection: (current['wind_direction_10m'] as num).toInt(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      visibility: vis,
      tempMin: (tempMins[0] as num).toDouble(),
      tempMax: (tempMaxs[0] as num).toDouble(),
      sunrise: sunrises.isNotEmpty ? sunrises[0] as String : '',
      sunset: sunsets.isNotEmpty ? sunsets[0] as String : '',
      utcOffsetSeconds: (json['utc_offset_seconds'] as num?)?.toInt() ?? 0,
    );
  }
}
