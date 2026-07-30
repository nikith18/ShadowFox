import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/models/activity_record.dart';
import '../core/providers/activity_provider.dart';
import '../widgets/glass_card.dart';

/// History Screen – displays all recorded activities with search and filter.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _searchQuery = '';
  String _filterType = 'All';
  String _sortBy = 'Date ↓';

  final List<String> _workoutTypes = [
    'All',
    'walking',
    'running',
    'cycling',
    'rest'
  ];
  final List<String> _sortOptions = [
    'Date ↓',
    'Date ↑',
    'Steps ↓',
    'Calories ↓'
  ];

  @override
  Widget build(BuildContext context) {
    final activity = context.watch<ActivityProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _applyFilters(activity.history);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Activity History'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.darkBgGradient : AppColors.lightBgGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Search + Filter bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  children: [
                    // Search field
                    TextField(
                      onChanged: (v) =>
                          setState(() => _searchQuery = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Search activities…',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () =>
                                    setState(() => _searchQuery = ''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filter + Sort chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Type filter
                          ..._workoutTypes.map((type) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: ChoiceChip(
                                  label: Text(type),
                                  selected: _filterType == type,
                                  onSelected: (_) =>
                                      setState(() => _filterType = type),
                                ),
                              )),
                          const SizedBox(width: 8),
                          // Sort dropdown
                          DropdownButton<String>(
                            value: _sortBy,
                            underline: const SizedBox(),
                            items: _sortOptions
                                .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s,
                                        style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (v) => setState(() => _sortBy = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Results count
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('${filtered.length} records',
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No activities found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) =>
                            _buildHistoryItem(context, filtered[i], activity),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, ActivityRecord record, ActivityProvider activity) {
    final icons = {
      'walking': '🚶',
      'running': '🏃',
      'cycling': '🚴',
      'rest': '💤'
    };
    final dateStr = DateFormat('EEE, MMM d yyyy').format(record.date);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(icons[record.workoutType] ?? '💪',
                  style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${record.workoutType[0].toUpperCase()}${record.workoutType.substring(1)} • ${record.activeMinutes} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${record.steps}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppColors.steps)),
              const Text('steps', style: TextStyle(fontSize: 10)),
              Text('${record.caloriesBurned.toStringAsFixed(0)} kcal',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.calories)),
            ],
          ),

          // Delete
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () => activity.deleteRecord(record.id),
          ),
        ],
      ),
    );
  }

  List<ActivityRecord> _applyFilters(List<ActivityRecord> records) {
    var list = records.toList();

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((r) =>
              r.workoutType.contains(_searchQuery) ||
              r.date.toString().contains(_searchQuery))
          .toList();
    }

    // Type filter
    if (_filterType != 'All') {
      list = list.where((r) => r.workoutType == _filterType).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'Date ↓':
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'Date ↑':
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'Steps ↓':
        list.sort((a, b) => b.steps.compareTo(a.steps));
        break;
      case 'Calories ↓':
        list.sort((a, b) => b.caloriesBurned.compareTo(a.caloriesBurned));
        break;
    }

    return list;
  }
}
