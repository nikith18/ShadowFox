import 'package:flutter/material.dart';
import 'dart:math' as math;

/// An animated circular progress ring that smoothly fills from 0 to [progress].
/// Wrapped in RepaintBoundary so the CustomPaint layer repaints independently,
/// preventing the surrounding widget tree from being involved in each frame.
class AnimatedProgressRing extends StatefulWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Color? progressEndColor;
  final Widget? centerChild;
  final Duration animationDuration;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.size = 160,
    this.strokeWidth = 14,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.progressColor = const Color(0xFF6C63FF),
    this.progressEndColor,
    this.centerChild,
    this.animationDuration = const Duration(milliseconds: 900),
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = Tween<double>(begin: 0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RingPainter(
                    progress: _animation.value,
                    strokeWidth: widget.strokeWidth,
                    backgroundColor: widget.backgroundColor,
                    progressColor: widget.progressColor,
                    progressEndColor: widget.progressEndColor,
                  ),
                ),
                if (widget.centerChild != null) widget.centerChild!,
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Color? progressEndColor;

  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
    this.progressEndColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final Paint progressPaint;
    if (progressEndColor != null) {
      progressPaint = Paint()
        ..shader = SweepGradient(
          colors: [progressColor, progressEndColor!],
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + (2 * math.pi * progress),
          transform: const GradientRotation(-math.pi / 2),
        ).createShader(rect)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    } else {
      progressPaint = Paint()
        ..color = progressColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
    }

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
