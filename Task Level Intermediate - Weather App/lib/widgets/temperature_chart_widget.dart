import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forecast_model.dart';
import '../providers/settings_provider.dart';
import 'glass_card.dart';

class TemperatureChartWidget extends StatelessWidget {
  final List<HourlyItem> hourlyData;

  const TemperatureChartWidget({super.key, required this.hourlyData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final reduceMotion = context.watch<SettingsProvider>().reduceMotion;

    if (hourlyData.isEmpty) return const SizedBox.shrink();

    final items = hourlyData.take(12).toList();
    if (items.length < 2) return const SizedBox.shrink();

    final maxTemp = items
        .map((e) => e.temperature)
        .reduce((a, b) => a > b ? a : b);
    final minTemp = items
        .map((e) => e.temperature)
        .reduce((a, b) => a < b ? a : b);
    final tempRange = (maxTemp - minTemp).clamp(5.0, 100.0);

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: textColor.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '12-Hour Trend',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(seconds: 2),
              curve: Curves.easeOutQuart,
              builder: (context, val, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _ChartPainter(
                    items: items,
                    minTemp: minTemp,
                    tempRange: tempRange,
                    progress: val,
                    isDark: isDark,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<HourlyItem> items;
  final double minTemp;
  final double tempRange;
  final double progress;
  final bool isDark;

  _ChartPainter({
    required this.items,
    required this.minTemp,
    required this.tempRange,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;

    final width = size.width;
    final height = size.height;

    final dx = width / (items.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < items.length; i++) {
      final normalizedY = (items[i].temperature - minTemp) / tempRange;
      final y = height - 10 - (normalizedY * (height - 20));
      points.add(Offset(i * dx, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 1; i < items.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];

      final controlPointX = p0.dx + (p1.dx - p0.dx) / 2;
      path.cubicTo(controlPointX, p0.dy, controlPointX, p1.dy, p1.dx, p1.dy);
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width * progress, height));

    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, height);
    fillPath.lineTo(points.first.dx, height);
    fillPath.close();

    final gradientFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? Colors.blueAccent : Colors.blue).withValues(alpha: 0.3),
          (isDark ? Colors.blueAccent : Colors.blue).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    canvas.drawPath(fillPath, gradientFill);

    final linePaint = Paint()
      ..color = isDark ? Colors.blueAccent : Colors.blue.shade700
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = (isDark ? Colors.blueAccent : Colors.blue).withValues(
        alpha: 0.8,
      );
    final corePaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 4.5, dotPaint);
      canvas.drawCircle(p, 2.5, corePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
