import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final isF = context.watch<SettingsProvider>().isFahrenheit;

    return GlassCard(
      borderRadius: 28,
      blurStrength: 16,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (weather.adminArea.isNotEmpty ||
                        weather.country.isNotEmpty)
                      Text(
                        [
                          weather.adminArea,
                          weather.country,
                        ].where((s) => s.isNotEmpty).join(', '),
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.65),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(wmoToIcon(weather.weatherCode), size: 52, color: textColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            tempString(weather.temperature, isFahrenheit: isF),
            style: TextStyle(
              color: textColor,
              fontSize: 76,
              fontWeight: FontWeight.w200,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            wmoToDescription(weather.weatherCode),
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _Chip(
                label:
                    'Feels like ${tempString(weather.feelsLike, isFahrenheit: isF)}',
                color: textColor,
              ),
              _Chip(
                label:
                    'H:${tempString(weather.tempMax, isFahrenheit: isF)}  L:${tempString(weather.tempMin, isFahrenheit: isF)}',
                color: textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.withValues(alpha: 0.9),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
