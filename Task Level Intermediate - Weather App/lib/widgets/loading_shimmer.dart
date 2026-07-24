import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'glass_card.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.3);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.6);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ShimmerPlaceholder(height: 200, borderRadius: 28),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _ShimmerPlaceholder(height: 90, borderRadius: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ShimmerPlaceholder(height: 90, borderRadius: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _ShimmerPlaceholder(height: 90, borderRadius: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _ShimmerPlaceholder(height: 90, borderRadius: 18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _ShimmerPlaceholder(height: 130, borderRadius: 20),
          const SizedBox(height: 16),
          const _ShimmerPlaceholder(height: 200, borderRadius: 20),
        ],
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  final double height;
  final double borderRadius;
  const _ShimmerPlaceholder({required this.height, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: borderRadius,
      padding: EdgeInsets.zero,
      child: SizedBox(height: height, width: double.infinity),
    );
  }
}
