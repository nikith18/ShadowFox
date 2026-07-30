import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/activity_provider.dart';
import '../core/providers/user_profile_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/stat_card.dart';

/// Home Dashboard – the main screen users see after launch.
/// Shows today's stats, goal ring, streak, and quick navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityProvider>();
    final profile = context.watch<UserProfileProvider>().profile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stepsProgress =
        (activity.todaySteps / profile.dailyStepGoal).clamp(0.0, 1.0);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: activity.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => activity.loadDataset(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              SlideTransition(
                                position: _headerSlide,
                                child: FadeTransition(
                                  opacity: _headerFade,
                                  child: _buildHeader(
                                      context, profile.name, today),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Goal progress ring card
                              _buildProgressCard(context, activity,
                                  stepsProgress, profile.dailyStepGoal, isDark),

                              const SizedBox(height: 20),

                              // 4 stat cards in a grid
                              _buildStatGrid(
                                  context, activity, profile, isDark),

                              const SizedBox(height: 20),

                              // Weekly summary
                              _buildWeeklySummary(context, activity, isDark),

                              const SizedBox(height: 20),

                              // Streak card
                              _buildStreakCard(context, activity),

                              const SizedBox(height: 20),

                              // Quick nav buttons
                              _buildQuickNav(context),

                              const SizedBox(height: 20),

                              // Error message if any
                              if (activity.error != null)
                                _buildErrorBanner(context, activity),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String today) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${name.split(' ').first} 👋',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(today, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/profile'),
          child: Hero(
            tag: 'profile-avatar',
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
              ),
              child: const Center(
                child: Text('🏃', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(BuildContext context, ActivityProvider activity,
      double stepsProgress, int goalSteps, bool isDark) {
    final pct = (stepsProgress * 100).toStringAsFixed(0);
    return GlassCard(
      child: Row(
        children: [
          AnimatedProgressRing(
            progress: stepsProgress,
            size: 130,
            strokeWidth: 13,
            progressColor: AppColors.primary,
            progressEndColor: AppColors.accent,
            backgroundColor: isDark
                ? Colors.white12
                : AppColors.primary.withValues(alpha: 0.12),
            centerChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$pct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'Goal',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Today's Goal",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _goalRow(
                    'Steps', '${activity.todaySteps}', Icons.directions_walk),
                _goalRow(
                    'Calories',
                    '${activity.todayCalories.toStringAsFixed(0)} kcal',
                    Icons.local_fire_department),
                _goalRow(
                    'Distance',
                    '${activity.todayDistanceKm.toStringAsFixed(1)} km',
                    Icons.route),
                _goalRow('Active', '${activity.todayActiveMinutes} min',
                    Icons.timer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textDarkSecondary)),
          const Spacer(),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStatGrid(BuildContext context, ActivityProvider activity,
      dynamic profile, bool isDark) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatCard(
                label: 'Steps',
                value: _formatNumber(activity.todaySteps),
                unit: 'steps',
                icon: Icons.directions_walk,
                gradient: AppColors.stepsGradient,
                progress: (activity.todaySteps / profile.dailyStepGoal)
                    .clamp(0.0, 1.0),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                label: 'Calories',
                value: activity.todayCalories.toStringAsFixed(0),
                unit: 'kcal',
                icon: Icons.local_fire_department,
                gradient: AppColors.caloriesGradient,
                progress: (activity.todayCalories / profile.dailyCalorieGoal)
                    .clamp(0.0, 1.0),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                label: 'Distance',
                value: activity.todayDistanceKm.toStringAsFixed(1),
                unit: 'km',
                icon: Icons.route,
                gradient: AppColors.distanceGradient,
                progress: (activity.todayDistanceKm / profile.dailyDistanceGoal)
                    .clamp(0.0, 1.0),
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                label: 'Active Time',
                value: '${activity.todayActiveMinutes}',
                unit: 'min',
                icon: Icons.timer,
                gradient: AppColors.activeGradient,
                progress: (activity.todayActiveMinutes /
                        profile.dailyActiveMinutesGoal)
                    .clamp(0.0, 1.0),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeeklySummary(
      BuildContext context, ActivityProvider activity, bool isDark) {
    final weekData = activity.last7Days;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Summary',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (weekData.isEmpty)
            const Text('No data for this week yet.')
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekData.map((r) {
                final h = r.steps / 15000.0;
                return Column(
                  children: [
                    Container(
                      width: 28,
                      height: 60,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                        width: 18,
                        height: (h.clamp(0.05, 1.0) * 60),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dayLabel(r.date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                );
              }).toList(),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryChip(
                  context,
                  '${activity.averageDailySteps.toStringAsFixed(0)}',
                  'Avg Steps'),
              _summaryChip(
                  context,
                  '${activity.averageDailyCalories.toStringAsFixed(0)} kcal',
                  'Avg Calories'),
              _summaryChip(
                  context, '${activity.activeDaysCount}', 'Active Days'),
            ],
          )
        ],
      ),
    );
  }

  Widget _summaryChip(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.primary)),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, ActivityProvider activity) {
    return GlassCard(
      gradient: AppColors.primaryGradient,
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${activity.streakCount}-Day Streak!',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                activity.streakCount == 0
                    ? 'Start your streak today!'
                    : 'Keep it up, you\'re on fire!',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickNav(BuildContext context) {
    final items = [
      {'icon': Icons.bar_chart, 'label': 'Analytics', 'route': '/analytics'},
      {'icon': Icons.history, 'label': 'History', 'route': '/history'},
      {'icon': Icons.flag, 'label': 'Goals', 'route': '/goals'},
      {'icon': Icons.person, 'label': 'Profile', 'route': '/profile'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Access',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: items.map((item) {
            return GestureDetector(
              onTap: () =>
                  Navigator.of(context).pushNamed(item['route'] as String),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                child: Column(
                  children: [
                    Icon(item['icon'] as IconData,
                        color: AppColors.primary, size: 24),
                    const SizedBox(height: 6),
                    Text(item['label'] as String,
                        style: const TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(BuildContext context, ActivityProvider activity) {
    return GlassCard(
      borderColor: AppColors.error.withValues(alpha: 0.5),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
              child:
                  Text(activity.error!, style: const TextStyle(fontSize: 13))),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: activity.clearError,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }

  String _dayLabel(DateTime date) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[date.weekday - 1];
  }
}
