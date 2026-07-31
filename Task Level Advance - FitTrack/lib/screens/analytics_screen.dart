import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/activity_provider.dart';
import '../core/models/activity_record.dart';
import '../widgets/glass_card.dart';

/// Analytics Screen – visualizes fitness data using fl_chart.
/// Shows daily steps bar chart, weekly calories line chart, and activity pie chart.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.transparent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Steps'),
            Tab(text: 'Calories'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: activity.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStepsTab(context, activity, isDark),
                    _buildCaloriesTab(context, activity, isDark),
                    _buildActivityTab(context, activity, isDark),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── STEPS TAB ──────────────────────────────────────────────────

  Widget _buildStepsTab(
      BuildContext context, ActivityProvider activity, bool isDark) {
    final data = activity.last7Days;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Summary chips
          _buildSummaryRow(context, activity),
          const SizedBox(height: 16),

          // Bar chart
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Steps (Last 7 Days)',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                data.isEmpty
                    ? const _EmptyChartPlaceholder()
                    : RepaintBoundary(
                        child: SizedBox(
                          height: 200,
                          child: BarChart(_buildStepsBarChart(data, isDark)),
                        ),
                      ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Monthly steps line chart
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly Steps Trend',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                activity.last30Days.isEmpty
                    ? const _EmptyChartPlaceholder()
                    : RepaintBoundary(
                        child: SizedBox(
                          height: 180,
                          child: LineChart(_buildStepsLineChart(
                              activity.last30Days, isDark)),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildStepsBarChart(List<ActivityRecord> data, bool isDark) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY:
          data.map((r) => r.steps.toDouble()).reduce((a, b) => a > b ? a : b) *
              1.2,
      barGroups: data.asMap().entries.map((e) {
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.steps.toDouble(),
              gradient: AppColors.stepsGradient,
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (val, _) => Text(
              '${(val / 1000).toStringAsFixed(0)}k',
              style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : Colors.black38),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) {
              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final idx = val.toInt();
              if (idx < 0 || idx >= data.length) return const SizedBox();
              return Text(days[data[idx].date.weekday - 1],
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black38));
            },
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: isDark ? Colors.white10 : Colors.black12,
          strokeWidth: 1,
        ),
      ),
    );
  }

  LineChartData _buildStepsLineChart(List<ActivityRecord> data, bool isDark) {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: data
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.steps.toDouble()))
              .toList(),
          isCurved: true,
          gradient: AppColors.primaryGradient,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                Colors.transparent
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (val, _) => Text(
              '${(val / 1000).toStringAsFixed(0)}k',
              style: TextStyle(
                  fontSize: 9, color: isDark ? Colors.white38 : Colors.black38),
            ),
          ),
        ),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
          color: isDark ? Colors.white10 : Colors.black12,
          strokeWidth: 1,
        ),
      ),
    );
  }

  // ─── CALORIES TAB ────────────────────────────────────────────────

  Widget _buildCaloriesTab(
      BuildContext context, ActivityProvider activity, bool isDark) {
    final data = activity.last7Days;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Calories Burned',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                data.isEmpty
                    ? const _EmptyChartPlaceholder()
                    : RepaintBoundary(
                        child: SizedBox(
                          height: 200,
                          child: BarChart(_buildCaloriesBarChart(data, isDark)),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Avg Daily Calories',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statChip(
                        context,
                        activity.averageDailyCalories.toStringAsFixed(0),
                        'kcal / day',
                        AppColors.calories),
                    _statChip(
                        context,
                        activity.totalDistanceKm.toStringAsFixed(0),
                        'km Total',
                        AppColors.distance),
                    _statChip(context, '${activity.activeDaysCount}',
                        'Active Days', AppColors.success),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildCaloriesBarChart(List<ActivityRecord> data, bool isDark) {
    final maxVal =
        data.map((r) => r.caloriesBurned).reduce((a, b) => a > b ? a : b) * 1.2;
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxVal,
      barGroups: data.asMap().entries.map((e) {
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value.caloriesBurned,
              gradient: AppColors.caloriesGradient,
              width: 18,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        );
      }).toList(),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (val, _) => Text(
              val.toStringAsFixed(0),
              style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.white54 : Colors.black38),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (val, _) {
              const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              final idx = val.toInt();
              if (idx < 0 || idx >= data.length) return const SizedBox();
              return Text(days[data[idx].date.weekday - 1],
                  style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black38));
            },
          ),
        ),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(
            color: isDark ? Colors.white10 : Colors.black12, strokeWidth: 1),
      ),
    );
  }

  // ─── ACTIVITY PIE TAB ────────────────────────────────────────────

  Widget _buildActivityTab(
      BuildContext context, ActivityProvider activity, bool isDark) {
    final last30 = activity.last30Days;

    final Map<String, int> typeCounts = {};
    for (final r in last30) {
      typeCounts[r.workoutType] = (typeCounts[r.workoutType] ?? 0) + 1;
    }

    final colors = [
      AppColors.steps,
      AppColors.calories,
      AppColors.distance,
      AppColors.activeMinutes,
      AppColors.primary
    ];
    final keys = typeCounts.keys.toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Activity Distribution (30 days)',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                typeCounts.isEmpty
                    ? const _EmptyChartPlaceholder()
                    : RepaintBoundary(
                        child: SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sections: keys.asMap().entries.map((e) {
                                final count = typeCounts[e.value]!;
                                final pct = (count / last30.length * 100)
                                    .toStringAsFixed(0);
                                return PieChartSectionData(
                                  value: count.toDouble(),
                                  color: colors[e.key % colors.length],
                                  title: '$pct%',
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  radius: 80,
                                );
                              }).toList(),
                              sectionsSpace: 3,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: keys.asMap().entries.map((e) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: colors[e.key % colors.length],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(e.value, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared helpers ──────────────────────────────────────────────

  Widget _buildSummaryRow(BuildContext context, ActivityProvider activity) {
    return Row(
      children: [
        Expanded(
            child: _statChip(
                context,
                activity.averageDailySteps.toStringAsFixed(0),
                'Avg Steps',
                AppColors.steps)),
        const SizedBox(width: 10),
        Expanded(
            child: _statChip(context, '${activity.activeDaysCount}',
                'Active Days', AppColors.success)),
        const SizedBox(width: 10),
        Expanded(
            child: _statChip(
                context,
                '${activity.totalDistanceKm.toStringAsFixed(0)}km',
                'Total Dist.',
                AppColors.distance)),
      ],
    );
  }

  Widget _statChip(
      BuildContext context, String value, String label, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _EmptyChartPlaceholder extends StatelessWidget {
  const _EmptyChartPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Center(
          child: Text('No data available yet.\nLoad the dataset to see charts.',
              textAlign: TextAlign.center)),
    );
  }
}
