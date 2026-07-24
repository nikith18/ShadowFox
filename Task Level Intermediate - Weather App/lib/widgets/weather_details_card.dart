import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_utils.dart';
import 'glass_card.dart';

class WeatherDetailsCard extends StatelessWidget {
  final WeatherModel weather;

  const WeatherDetailsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Item(Icons.water_drop_rounded, 'Humidity', '${weather.humidity}%'),
      _Item(
        Icons.air_rounded,
        'Wind',
        '${weather.windSpeed.toStringAsFixed(1)} m/s  ${windDirectionLabel(weather.windDirection.toDouble())}',
      ),
      _Item(
        Icons.compress_rounded,
        'Pressure',
        '${weather.pressure.round()} hPa',
      ),
      _Item(
        Icons.visibility_rounded,
        'Visibility',
        visibilityString(weather.visibility),
      ),
      _Item(
        Icons.wb_twilight_rounded,
        'Sunrise',
        formatIsoTime(weather.sunrise),
      ),
      _Item(Icons.nightlight_round, 'Sunset', formatIsoTime(weather.sunset)),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 480 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: items.map((item) => _DetailCard(item: item)).toList(),
        );
      },
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final String value;
  const _Item(this.icon, this.label, this.value);
}

class _DetailCard extends StatelessWidget {
  final _Item item;
  const _DetailCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);

    return GlassCard(
      borderRadius: 18,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(item.icon, color: textColor.withValues(alpha: 0.65), size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                item.label,
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
