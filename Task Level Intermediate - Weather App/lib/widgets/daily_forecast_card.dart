import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../utils/weather_utils.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

class DailyForecastCard extends StatelessWidget {
  final List<DailyItem> days;

  const DailyForecastCard({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final isF = context.watch<SettingsProvider>().isFahrenheit;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  color: textColor.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '${days.length}-Day Forecast',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...days.map(
            (day) => _DailyTile(item: day, textColor: textColor, isF: isF),
          ),
        ],
      ),
    );
  }
}

class _DailyTile extends StatelessWidget {
  final DailyItem item;
  final Color textColor;
  final bool isF;

  const _DailyTile({
    required this.item,
    required this.textColor,
    required this.isF,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        now.day == item.date.day &&
        now.month == item.date.month &&
        now.year == item.date.year;

    final dateStr = isToday ? 'Today' : DateFormat('EEEE').format(item.date);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              dateStr,
              style: TextStyle(
                color: textColor.withValues(alpha: isToday ? 1.0 : 0.8),
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(wmoToIcon(item.weatherCode), color: textColor, size: 22),
                if (item.precipitationProbabilityMax > 20) ...[
                  const SizedBox(width: 4),
                  Text(
                    '${item.precipitationProbabilityMax}%',
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    tempString(item.tempMin, isFahrenheit: isF),
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.6),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(
                  width: 46,
                  child: Text(
                    tempString(item.tempMax, isFahrenheit: isF),
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
