import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/models/fitness_goal.dart';
import '../core/providers/goals_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/goal_card.dart';

/// Goals Screen – lets users create, edit, delete, and track fitness goals.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goals = context.watch<GoalsProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Fitness Goals'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          tabs: [
            Tab(text: 'Active (${goals.activeGoals.length})'),
            Tab(text: 'Completed (${goals.completedGoals.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
        backgroundColor: AppColors.primary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildGoalList(context, goals.activeGoals, goals, isActive: true),
              _buildGoalList(context, goals.completedGoals, goals,
                  isActive: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalList(
      BuildContext context, List<FitnessGoal> items, GoalsProvider goals,
      {required bool isActive}) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isActive ? '🎯' : '🏆', style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              isActive
                  ? 'No active goals yet.\nTap + to create one!'
                  : 'No completed goals yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final goal = items[i];
        return GoalCard(
          goal: goal,
          onEdit: () => _showAddGoalDialog(context, existing: goal),
          onDelete: () => _confirmDelete(context, goals, goal.id),
          onComplete: () => goals.markComplete(goal.id),
        );
      },
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, GoalsProvider goals, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) goals.deleteGoal(id);
  }

  Future<void> _showAddGoalDialog(BuildContext context,
      {FitnessGoal? existing}) async {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final targetController = TextEditingController(
        text: existing?.targetValue.toStringAsFixed(0) ?? '');
    GoalType selectedType = existing?.type ?? GoalType.steps;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (ctx, setSheetState) => GlassCard(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing != null ? 'Edit Goal' : 'Create New Goal',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Goal type selector
                  Text('Goal Type',
                      style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: GoalType.values.map((type) {
                      final goal = FitnessGoal(
                        id: '',
                        title: '',
                        type: type,
                        targetValue: 0,
                        createdAt: DateTime.now(),
                      );
                      return ChoiceChip(
                        label: Text('${goal.typeIcon} ${type.name}'),
                        selected: selectedType == type,
                        onSelected: (_) =>
                            setSheetState(() => selectedType = type),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Title field
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                        labelText: 'Goal Title',
                        hintText: 'e.g. Walk 10,000 steps'),
                  ),
                  const SizedBox(height: 12),

                  // Target field
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Value',
                      hintText:
                          selectedType == GoalType.steps ? '10000' : '500',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        final target =
                            double.tryParse(targetController.text) ?? 0;
                        if (title.isEmpty || target <= 0) return;
                        final goalsProvider = context.read<GoalsProvider>();
                        if (existing != null) {
                          goalsProvider.updateGoal(existing.copyWith(
                            title: title,
                            type: selectedType,
                            targetValue: target,
                          ));
                        } else {
                          goalsProvider.addGoal(FitnessGoal(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: title,
                            type: selectedType,
                            targetValue: target,
                            createdAt: DateTime.now(),
                          ));
                        }
                        Navigator.pop(ctx);
                      },
                      child: Text(
                          existing != null ? 'Save Changes' : 'Create Goal'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
