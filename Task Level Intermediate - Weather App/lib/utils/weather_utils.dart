import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


String wmoToCondition(int code) {
  if (code == 0) return 'Clear';
  if (code == 1) return 'Mainly Clear';
  if (code == 2) return 'Partly Cloudy';
  if (code == 3) return 'Overcast';
  if (code >= 45 && code <= 48) return 'Fog';
  if (code >= 51 && code <= 55) return 'Drizzle';
  if (code >= 56 && code <= 57) return 'Freezing Drizzle';
  if (code >= 61 && code <= 65) return 'Rain';
  if (code >= 66 && code <= 67) return 'Freezing Rain';
  if (code >= 71 && code <= 75) return 'Snow';
  if (code == 77) return 'Snow Grains';
  if (code >= 80 && code <= 82) return 'Rain Showers';
  if (code >= 85 && code <= 86) return 'Snow Showers';
  if (code >= 95 && code <= 96) return 'Thunderstorm';
  if (code >= 99) return 'Thunderstorm with Hail';
  return 'Unknown';
}

String wmoToDescription(int code) {
  if (code == 0) return 'Clear sky';
  if (code == 1) return 'Mainly clear';
  if (code == 2) return 'Partly cloudy';
  if (code == 3) return 'Overcast';
  if (code == 45) return 'Foggy';
  if (code == 48) return 'Depositing rime fog';
  if (code == 51) return 'Light drizzle';
  if (code == 53) return 'Moderate drizzle';
  if (code == 55) return 'Dense drizzle';
  if (code == 56) return 'Light freezing drizzle';
  if (code == 57) return 'Heavy freezing drizzle';
  if (code == 61) return 'Slight rain';
  if (code == 63) return 'Moderate rain';
  if (code == 65) return 'Heavy rain';
  if (code == 66) return 'Light freezing rain';
  if (code == 67) return 'Heavy freezing rain';
  if (code == 71) return 'Slight snowfall';
  if (code == 73) return 'Moderate snowfall';
  if (code == 75) return 'Heavy snowfall';
  if (code == 77) return 'Snow grains';
  if (code == 80) return 'Slight rain shower';
  if (code == 81) return 'Moderate rain shower';
  if (code == 82) return 'Violent rain shower';
  if (code == 85) return 'Slight snow shower';
  if (code == 86) return 'Heavy snow shower';
  if (code == 95) return 'Thunderstorm';
  if (code == 96) return 'Thunderstorm with hail';
  if (code == 99) return 'Thunderstorm with heavy hail';
  return 'Unknown conditions';
}

IconData wmoToIcon(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code == 1 || code == 2) return Icons.wb_cloudy_rounded;
  if (code == 3) return Icons.cloud_rounded;
  if (code >= 45 && code <= 48) return Icons.foggy;
  if (code >= 51 && code <= 57) return Icons.grain_rounded;
  if (code >= 61 && code <= 67) return Icons.water_drop_rounded;
  if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
  if (code >= 80 && code <= 82) return Icons.shower_rounded;
  if (code >= 85 && code <= 86) return Icons.cloudy_snowing;
  if (code >= 95) return Icons.thunderstorm_rounded;
  return Icons.wb_cloudy_rounded;
}

enum WeatherCategory { clear, partlyCloudy, cloudy, fog, rain, snow, storm }

WeatherCategory wmoToCategory(int code) {
  if (code == 0 || code == 1) return WeatherCategory.clear;
  if (code == 2) return WeatherCategory.partlyCloudy;
  if (code == 3) return WeatherCategory.cloudy;
  if (code >= 45 && code <= 48) return WeatherCategory.fog;
  if (code >= 51 && code <= 82) return WeatherCategory.rain;
  if (code >= 71 && code <= 77 || code >= 85 && code <= 86) {
    return WeatherCategory.snow;
  }
  if (code >= 95) return WeatherCategory.storm;
  return WeatherCategory.cloudy;
}

List<Color> wmoToGradient(int code, bool isDark) {
  final cat = wmoToCategory(code);
  if (isDark) {
    return switch (cat) {
      WeatherCategory.clear => [
        const Color(0xFF0D1B4A),
        const Color(0xFF1A3070),
        const Color(0xFF060D2A),
      ],
      WeatherCategory.partlyCloudy => [
        const Color(0xFF12234B),
        const Color(0xFF243565),
        const Color(0xFF080F25),
      ],
      WeatherCategory.cloudy => [
        const Color(0xFF1A2030),
        const Color(0xFF2A3040),
        const Color(0xFF0D1520),
      ],
      WeatherCategory.fog => [
        const Color(0xFF1C2535),
        const Color(0xFF2D3A4A),
        const Color(0xFF101820),
      ],
      WeatherCategory.rain => [
        const Color(0xFF0D1B3E),
        const Color(0xFF1A3060),
        const Color(0xFF0A1020),
      ],
      WeatherCategory.snow => [
        const Color(0xFF1A2540),
        const Color(0xFF2A3A5C),
        const Color(0xFF0D1528),
      ],
      WeatherCategory.storm => [
        const Color(0xFF1A1035),
        const Color(0xFF2D1B69),
        const Color(0xFF0A0A1A),
      ],
    };
  } else {
    return switch (cat) {
      WeatherCategory.clear => [
        const Color(0xFF1E88E5),
        const Color(0xFF42A5F5),
        const Color(0xFF0D47A1),
      ],
      WeatherCategory.partlyCloudy => [
        const Color(0xFF2979CC),
        const Color(0xFF5199E0),
        const Color(0xFF1560A8),
      ],
      WeatherCategory.cloudy => [
        const Color(0xFF607D8B),
        const Color(0xFF90A4AE),
        const Color(0xFF455A64),
      ],
      WeatherCategory.fog => [
        const Color(0xFF78909C),
        const Color(0xFFB0BEC5),
        const Color(0xFF546E7A),
      ],
      WeatherCategory.rain => [
        const Color(0xFF3A5A8A),
        const Color(0xFF5A82B4),
        const Color(0xFF2A4070),
      ],
      WeatherCategory.snow => [
        const Color(0xFFAABBCC),
        const Color(0xFFCCDDFF),
        const Color(0xFF889BAA),
      ],
      WeatherCategory.storm => [
        const Color(0xFF37374A),
        const Color(0xFF5A5A7A),
        const Color(0xFF2A2A3A),
      ],
    };
  }
}


String formatIsoTime(String isoTime) {
  try {
    final dt = DateTime.parse(isoTime);
    return DateFormat('h:mm a').format(dt);
  } catch (_) {
    return isoTime;
  }
}

String formatHour(DateTime dt) => DateFormat('h a').format(dt);

String formatDay(DateTime dt) {
  final now = DateTime.now();
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
    return 'Today';
  }
  if (dt.year == now.year && dt.month == now.month && dt.day == now.day + 1) {
    return 'Tomorrow';
  }
  return DateFormat('EEE').format(dt);
}

String formatFullDate(DateTime dt) =>
    DateFormat('EEEE, d MMMM yyyy').format(dt);

String formatHeaderDate() => formatFullDate(DateTime.now());

String tempString(double temp, {bool isFahrenheit = false}) {
  if (isFahrenheit) temp = (temp * 9 / 5) + 32;
  return '${temp.round()}°';
}

String windDirectionLabel(double degrees) {
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final idx = ((degrees + 22.5) / 45).floor() % 8;
  return dirs[idx];
}

String visibilityString(double? meters) {
  if (meters == null) return '—';
  final km = meters / 1000;
  if (km >= 10) return '10+ km';
  return '${km.toStringAsFixed(1)} km';
}
