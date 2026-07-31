import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/activity_provider.dart';
import '../core/providers/user_profile_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_progress_ring.dart';

/// Activity Tracking Screen – shows live or dataset-based activity metrics.
/// In dataset mode it displays today's parsed record.
/// In sensor mode (future) it would show live updates.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityProvider>();
    final profile = context.watch<UserProfileProvider>().profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stepsProgress =
        (activity.todaySteps / profile.dailyStepGoal).clamp(0.0, 1.0);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Activity Tracking'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Big progress ring
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        activity.useSensorMode
                            ? '🎙️ Live Tracking'
                            : '📊 Dataset Mode',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: AnimatedProgressRing(
                          progress: stepsProgress,
                          size: 180,
                          strokeWidth: 16,
                          progressColor: AppColors.steps,
                          progressEndColor: AppColors.primary,
                          backgroundColor: isDark
                              ? Colors.white12
                              : AppColors.primary.withValues(alpha: 0.1),
                          centerChild: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${activity.todaySteps}',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('steps',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Goal: ${profile.dailyStepGoal} steps',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Metrics in 2x2 grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    _metricCard(
                        context,
                        '🔥 Calories',
                        activity.todayCalories.toStringAsFixed(0),
                        'kcal',
                        AppColors.calories),
                    _metricCard(
                        context,
                        '📍 Distance',
                        activity.todayDistanceKm.toStringAsFixed(2),
                        'km',
                        AppColors.distance),
                    _metricCard(
                        context,
                        '⏱ Active',
                        '${activity.todayActiveMinutes}',
                        'min',
                        AppColors.activeMinutes),
                    _metricCard(
                        context,
                        '❤️ Heart Rate',
                        activity.todayRecord?.heartRateAvg != null &&
                                activity.todayRecord!.heartRateAvg > 0
                            ? activity.todayRecord!.heartRateAvg
                                .toStringAsFixed(0)
                            : '--',
                        'bpm',
                        AppColors.heartRate),
                  ],
                ),

                const SizedBox(height: 16),

                // Workout type card
                if (activity.todayRecord != null)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Workout',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _workoutTypeChip(
                            context, activity.todayRecord!.workoutType),
                        const SizedBox(height: 8),
                        if (activity.todayRecord!.sleepHours > 0)
                          Row(
                            children: [
                              const Text('😴 Sleep: ',
                                  style: TextStyle(fontSize: 14)),
                              Text(
                                  '${activity.todayRecord!.sleepHours.toStringAsFixed(1)} hrs',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Dataset info banner
                GlassCard(
                  borderColor: AppColors.accent.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      const Text('ℹ️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activity.useSensorMode
                              ? 'Live sensor tracking is active. Data updates in real time.'
                              : 'Displaying data from the bundled fitness dataset. Toggle sensor mode in Settings.',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricCard(BuildContext context, String label, String value,
      String unit, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(unit, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workoutTypeChip(BuildContext context, String type) {
    final Map<String, String> icons = {
      'walking': '🚶',
      'running': '🏃',
      'cycling': '🚴',
      'rest': '💤',
      'other': '💪',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        '${icons[type] ?? '💪'} ${type[0].toUpperCase()}${type.substring(1)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
