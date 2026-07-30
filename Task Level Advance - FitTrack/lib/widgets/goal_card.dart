import 'package:flutter/material.dart';
import '../core/models/fitness_goal.dart';
import '../core/constants/app_colors.dart';
import 'glass_card.dart';

/// Displays a single fitness goal with progress bar and action buttons.
class GoalCard extends StatelessWidget {
  final FitnessGoal goal;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onComplete;

  const GoalCard({
    super.key,
    required this.goal,
    this.onEdit,
    this.onDelete,
    this.onComplete,
  });

  Color get _goalColor {
    switch (goal.type) {
      case GoalType.steps:
        return AppColors.steps;
      case GoalType.calories:
        return AppColors.calories;
      case GoalType.distance:
        return AppColors.distance;
      case GoalType.activeMinutes:
        return AppColors.activeMinutes;
      case GoalType.weeklyWorkouts:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (goal.progressPercent * 100).toStringAsFixed(0);
    final isDone = goal.isCompleted;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon + title + menu
          Row(
            children: [
              Text(goal.typeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                    ),
                    Text(
                      '${goal.currentValue.toStringAsFixed(0)} / '
                      '${goal.targetValue.toStringAsFixed(0)} ${goal.unitLabel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isDone)
                const Icon(Icons.check_circle, color: AppColors.success)
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                    if (value == 'complete') onComplete?.call();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'complete', child: Text('Mark Complete')),
                    const PopupMenuItem(
                      value: 'delete',
                      child:
                          Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: goal.progressPercent,
              backgroundColor: _goalColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(_goalColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),

          // Percentage label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDone ? '✅ Completed!' : 'Progress: $pct%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDone ? AppColors.success : _goalColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isDone && goal.targetValue > goal.currentValue)
                Text(
                  '${(goal.targetValue - goal.currentValue).toStringAsFixed(0)} ${goal.unitLabel} left',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
