import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'glass_card.dart';

class SunPathWidget extends StatelessWidget {
  final WeatherModel weather;

  const SunPathWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final reduceMotion = context.watch<SettingsProvider>().reduceMotion;

    if (weather.sunrise.isEmpty || weather.sunset.isEmpty) {
      return const SizedBox.shrink();
    }

    final sr = DateTime.tryParse(weather.sunrise);
    final ss = DateTime.tryParse(weather.sunset);
    if (sr == null || ss == null) return const SizedBox.shrink();

    final nowUtc = DateTime.now().toUtc();
    final nowLocal = nowUtc.add(Duration(seconds: weather.utcOffsetSeconds));

    final totalDay = ss.difference(sr).inMinutes.toDouble();
    double progress = 0.0;
    if (totalDay > 0) {
      progress = nowLocal.difference(sr).inMinutes / totalDay;
    }
    progress = progress.clamp(0.0, 1.0);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_twilight_rounded,
                color: textColor.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Sunrise & Sunset',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 90,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(seconds: 2),
              curve: Curves.easeOutBack,
              builder: (context, val, _) {
                return CustomPaint(
                  size: const Size(double.infinity, 90),
                  painter: _SunPathPainter(progress: val, isDark: isDark),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeColumn(label: 'Sunrise', time: sr, color: textColor),
              _TimeColumn(label: 'Sunset', time: ss, color: textColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String label;
  final DateTime time;
  final Color color;

  const _TimeColumn({
    required this.label,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          DateFormat('h:mm a').format(time),
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SunPathPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _SunPathPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.2 : 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    _drawDashedArc(canvas, rect, pi, pi, trackPaint);

    final angle = pi + (progress * pi);
    final rx = size.width / 2;
    final ry = size.height;

    final cx = rect.center.dx;
    final cy = rect.center.dy;

    final sunX = cx + rx * cos(angle);
    final sunY = cy + ry * sin(angle);

    final sunColor = const Color(0xFFFFD54F);

    canvas.drawCircle(
      Offset(sunX, sunY),
      14,
      Paint()
        ..color = sunColor.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    canvas.drawCircle(
      Offset(sunX, sunY),
      8,
      Paint()
        ..color = sunColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2),
    );

    canvas.drawCircle(Offset(sunX, sunY), 4, Paint()..color = Colors.white);
  }

  void _drawDashedArc(
    Canvas canvas,
    Rect rect,
    double startAngle,
    double sweepAngle,
    Paint paint,
  ) {
    final path = Path()..addArc(rect, startAngle, sweepAngle);
    final dashWidth = 5.0;
    final dashSpace = 5.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final extractPath = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SunPathPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
