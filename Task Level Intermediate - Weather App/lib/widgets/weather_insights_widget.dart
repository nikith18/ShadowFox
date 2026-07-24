import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import 'glass_card.dart';

class WeatherInsightsWidget extends StatelessWidget {
  final WeatherModel weather;
  final ForecastModel forecast;

  const WeatherInsightsWidget({
    super.key,
    required this.weather,
    required this.forecast,
  });

  List<String> _generateInsights() {
    final insights = <String>[];

    final diff = (weather.feelsLike - weather.temperature).abs();
    if (diff > 2.0) {
      if (weather.feelsLike > weather.temperature) {
        insights.add('It feels warmer than the actual temperature.');
      } else {
        insights.add('Wind chill makes it feel colder than it is.');
      }
    }

    if (forecast.hourly.isNotEmpty) {
      final nextHours = forecast.hourly.take(6).toList();
      final rainHours = nextHours.where((e) => e.precipitationProbability > 40);
      if (rainHours.isNotEmpty) {
        insights.add('Expect precipitation in the next few hours.');
      } else {
        insights.add('No precipitation expected in the near future.');
      }
    }

    if (weather.windSpeed > 10.0) {
      insights.add('Strong winds detected. Hold onto your hat!');
    } else if (weather.windSpeed > 5.0) {
      insights.add('Breezy conditions outside.');
    }

    if (weather.visibility != null && weather.visibility! < 2000) {
      insights.add('Low visibility. Drive carefully.');
    }

    if (insights.isEmpty) {
      insights.add('Conditions are relatively calm right now.');
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final insights = _generateInsights();

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: textColor.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Insights',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: isDark ? Colors.greenAccent : Colors.green.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
