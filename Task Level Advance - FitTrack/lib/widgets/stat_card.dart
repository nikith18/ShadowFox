import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import 'glass_card.dart';

/// A compact statistics card showing an icon, value, label, and optional trend.
/// Used heavily on the Home Dashboard screen.
class StatCard extends StatefulWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Gradient gradient;
  final double? progress; // 0.0–1.0 for mini progress indicator
  final String? trend; // e.g. "+12%" or "–5%"

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.gradient,
    this.progress,
    this.trend,
  });

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _scaleAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with gradient background
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: widget.gradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 12),

                // Value + unit
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      widget.value,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                    ),
                    const SizedBox(width: 2),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        widget.unit,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                      ),
                    ),
                    if (widget.trend != null) ...[
                      const Spacer(),
                      Text(
                        widget.trend!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.trend!.startsWith('+')
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),

                // Label
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                // Optional mini progress bar
                if (widget.progress != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: widget.progress,
                      backgroundColor: isDark
                          ? Colors.white12
                          : AppColors.primary.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(
                        widget.gradient.colors.first,
                      ),
                      minHeight: 5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
