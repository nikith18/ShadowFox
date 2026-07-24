class HourlyItem {
  final DateTime time;
  final double temperature;
  final double feelsLike;
  final int weatherCode;
  final int precipitationProbability;
  final double precipitation;
  final double? visibility;

  const HourlyItem({
    required this.time,
    required this.temperature,
    required this.feelsLike,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.precipitation,
    this.visibility,
  });
}

class DailyItem {
  final DateTime date;
  final int weatherCode;
  final double tempMin;
  final double tempMax;
  final String sunrise;
  final String sunset;
  final int precipitationProbabilityMax;

  const DailyItem({
    required this.date,
    required this.weatherCode,
    required this.tempMin,
    required this.tempMax,
    required this.sunrise,
    required this.sunset,
    required this.precipitationProbabilityMax,
  });
}

class ForecastModel {
  final List<HourlyItem> hourly;
  final List<DailyItem> daily;

  const ForecastModel({required this.hourly, required this.daily});

  factory ForecastModel.fromOpenMeteo(Map<String, dynamic> json) {
    final utcOffsetSeconds = (json['utc_offset_seconds'] as num?)?.toInt() ?? 0;

    final hourlyJson = json['hourly'] as Map<String, dynamic>;
    final times = hourlyJson['time'] as List;
    final temps = hourlyJson['temperature_2m'] as List;
    final feels = hourlyJson['apparent_temperature'] as List;
    final codes = hourlyJson['weather_code'] as List;
    final precipProb = hourlyJson['precipitation_probability'] as List;
    final precip = hourlyJson['precipitation'] as List;
    final visList = hourlyJson['visibility'] as List?;

    final nowUtc = DateTime.now().toUtc();
    int startIdx = 0;
    for (int i = 0; i < times.length; i++) {
      final t = DateTime.parse(times[i] as String);
      final tUtc = t.subtract(Duration(seconds: utcOffsetSeconds));
      if (!tUtc.isBefore(nowUtc)) {
        startIdx = i;
        break;
      }
    }

    final hourly = <HourlyItem>[];
    for (int i = startIdx; i < times.length && i < startIdx + 24; i++) {
      hourly.add(
        HourlyItem(
          time: DateTime.parse(times[i] as String),
          temperature: (temps[i] as num).toDouble(),
          feelsLike: (feels[i] as num).toDouble(),
          weatherCode: (codes[i] as num).toInt(),
          precipitationProbability: (precipProb[i] as num?)?.toInt() ?? 0,
          precipitation: (precip[i] as num?)?.toDouble() ?? 0.0,
          visibility: visList != null ? (visList[i] as num?)?.toDouble() : null,
        ),
      );
    }

    final dailyJson = json['daily'] as Map<String, dynamic>;
    final dates = dailyJson['time'] as List;
    final dailyCodes = dailyJson['weather_code'] as List;
    final dMinTemps = dailyJson['temperature_2m_min'] as List;
    final dMaxTemps = dailyJson['temperature_2m_max'] as List;
    final sunrises = dailyJson['sunrise'] as List;
    final sunsets = dailyJson['sunset'] as List;
    final dPrecipProb = dailyJson['precipitation_probability_max'] as List?;

    final daily = <DailyItem>[];
    for (int i = 0; i < dates.length; i++) {
      daily.add(
        DailyItem(
          date: DateTime.parse(dates[i] as String),
          weatherCode: (dailyCodes[i] as num).toInt(),
          tempMin: (dMinTemps[i] as num).toDouble(),
          tempMax: (dMaxTemps[i] as num).toDouble(),
          sunrise: sunrises[i] as String,
          sunset: sunsets[i] as String,
          precipitationProbabilityMax: (dPrecipProb?[i] as num?)?.toInt() ?? 0,
        ),
      );
    }

    return ForecastModel(hourly: hourly, daily: daily);
  }
}
