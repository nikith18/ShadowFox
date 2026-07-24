import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../utils/weather_utils.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyItem> items;

  const HourlyForecastCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final isF = context.watch<SettingsProvider>().isFahrenheit;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 10),
            child: Text(
              'Next 24 Hours',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.65),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            height: 108,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _HourlyTile(
                  item: items[index],
                  textColor: textColor,
                  isFahrenheit: isF,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyTile extends StatelessWidget {
  final HourlyItem item;
  final Color textColor;
  final bool isFahrenheit;

  const _HourlyTile({
    required this.item,
    required this.textColor,
    required this.isFahrenheit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              formatHour(item.time),
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(wmoToIcon(item.weatherCode), color: textColor, size: 20),
            Text(
              tempString(item.temperature, isFahrenheit: isFahrenheit),
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.precipitationProbability > 0)
              Text(
                '${item.precipitationProbability}%',
                style: TextStyle(
                  color: Colors.blue.withValues(
                    alpha: isDark(context) ? 0.9 : 0.7,
                  ),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
}
