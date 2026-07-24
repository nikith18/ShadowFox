import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/location_model.dart';
import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';
import '../services/weather_service.dart';
import '../utils/weather_utils.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/weather_card.dart';
import '../widgets/weather_details_card.dart';
import '../widgets/hourly_forecast_card.dart';
import '../widgets/daily_forecast_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/sun_path_widget.dart';
import '../widgets/temperature_chart_widget.dart';
import '../widgets/weather_insights_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 480), () {
      if (value.trim().isEmpty) {
        context.read<WeatherProvider>().clearSearch();
      } else {
        context.read<WeatherProvider>().searchPlaces(value.trim());
      }
    });
  }

  void _onSearchSubmitted(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) return;
    context.read<WeatherProvider>().searchPlaces(value.trim());
  }

  void _onClear() {
    _searchController.clear();
    context.read<WeatherProvider>().clearSearch();
  }

  void _selectLocation(LocationResult loc) {
    _searchController.clear();
    context.read<WeatherProvider>().selectLocation(loc);
    _animateContent();
  }

  void _onLocationTap() {
    _searchController.clear();
    context.read<WeatherProvider>().clearSearch();
    context.read<WeatherProvider>().fetchByLocation();
    _animateContent();
  }

  void _animateContent() {
    _fadeCtrl.reset();
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final isDark = themeProvider.isDarkMode;
    final width = MediaQuery.of(context).size.width;

    final weatherCode = weatherProvider.weather?.weatherCode ?? 0;
    final gradient = wmoToGradient(weatherCode, isDark);
    final isLocating = weatherProvider.status == WeatherStatus.locating;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: width >= 900
                  ? _DesktopLayout(
                      weatherProvider: weatherProvider,
                      themeProvider: themeProvider,
                      searchController: _searchController,
                      isLocating: isLocating,
                      onSearchChanged: _onSearchChanged,
                      onSearchSubmitted: _onSearchSubmitted,
                      onClear: _onClear,
                      onLocationTap: _onLocationTap,
                      onSelectLocation: _selectLocation,
                      onRetry: weatherProvider.retry,
                      onOpenSettings: () => Geolocator.openAppSettings(),
                    )
                  : _MobileLayout(
                      weatherProvider: weatherProvider,
                      themeProvider: themeProvider,
                      searchController: _searchController,
                      isLocating: isLocating,
                      onSearchChanged: _onSearchChanged,
                      onSearchSubmitted: _onSearchSubmitted,
                      onClear: _onClear,
                      onLocationTap: _onLocationTap,
                      onSelectLocation: _selectLocation,
                      onRetry: weatherProvider.retry,
                      onOpenSettings: () => Geolocator.openAppSettings(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}


class _Header extends StatelessWidget {
  final bool isDark;
  final VoidCallback onThemeToggle;

  const _Header({required this.isDark, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weather',
                style: TextStyle(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                formatHeaderDate(),
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        _ThemeToggle(isDark: isDark, onToggle: onThemeToggle),
      ],
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 64,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: textColor.withValues(alpha: 0.18)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF82B1FF)
                      : const Color(0xFFFFD54F),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? const Color(0xFF82B1FF)
                                  : const Color(0xFFFFD54F))
                              .withValues(alpha: 0.45),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                  size: 14,
                  color: isDark
                      ? const Color(0xFF0D1B3E)
                      : const Color(0xFF7A5200),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final WeatherProvider provider;
  final bool isLocating;
  final ValueChanged<String> onChanged;
  final void Function(String) onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onLocationTap;
  final void Function(LocationResult) onSelect;

  const _SearchSection({
    required this.controller,
    required this.provider,
    required this.isLocating,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onLocationTap,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchBarWidget(
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onLocationTap: onLocationTap,
          onClear: onClear,
          isLocating: isLocating,
        ),
        if (provider.isSearching)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Colors.white54,
              minHeight: 2,
            ),
          ),
        if (provider.searchResults.isNotEmpty)
          _SearchResults(results: provider.searchResults, onSelect: onSelect),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<LocationResult> results;
  final void Function(LocationResult) onSelect;

  const _SearchResults({required this.results, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final bgColor = isDark
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.70);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: textColor.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: results.asMap().entries.map((entry) {
              final i = entry.key;
              final loc = entry.value;
              return Column(
                children: [
                  InkWell(
                    onTap: () => onSelect(loc),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (loc.subtitle.isNotEmpty)
                                  Text(
                                    loc.subtitle,
                                    style: TextStyle(
                                      color: textColor.withValues(alpha: 0.55),
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: textColor.withValues(alpha: 0.35),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < results.length - 1)
                    Divider(
                      height: 1,
                      color: textColor.withValues(alpha: 0.08),
                      indent: 44,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}


class _MobileLayout extends StatelessWidget {
  final WeatherProvider weatherProvider;
  final ThemeProvider themeProvider;
  final TextEditingController searchController;
  final bool isLocating;
  final ValueChanged<String> onSearchChanged;
  final void Function(String) onSearchSubmitted;
  final VoidCallback onClear;
  final VoidCallback onLocationTap;
  final void Function(LocationResult) onSelectLocation;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const _MobileLayout({
    required this.weatherProvider,
    required this.themeProvider,
    required this.searchController,
    required this.isLocating,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClear,
    required this.onLocationTap,
    required this.onSelectLocation,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                _Header(
                  isDark: isDark,
                  onThemeToggle: themeProvider.toggleTheme,
                ),
                const SizedBox(height: 16),
                _SearchSection(
                  controller: searchController,
                  provider: weatherProvider,
                  isLocating: isLocating,
                  onChanged: onSearchChanged,
                  onSubmitted: onSearchSubmitted,
                  onClear: onClear,
                  onLocationTap: onLocationTap,
                  onSelect: onSelectLocation,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _buildBody(context, weatherProvider, isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherProvider provider,
    bool isDark,
  ) {
    switch (provider.status) {
      case WeatherStatus.initial:
        return const EmptyStateWidget(key: ValueKey('empty'));
      case WeatherStatus.locating:
      case WeatherStatus.loading:
        return const LoadingShimmer(key: ValueKey('loading'));
      case WeatherStatus.error:
        return ErrorStateWidget(
          key: const ValueKey('error'),
          message: provider.errorMessage ?? 'An error occurred.',
          errorType: provider.errorType,
          onRetry: onRetry,
          onSearchManually: onClear,
          onOpenSettings: provider.errorType == WeatherErrorType.locationError
              ? onOpenSettings
              : null,
        );
      case WeatherStatus.loaded:
      case WeatherStatus.refreshing:
        final weather = provider.weather!;
        final forecast = provider.forecast!;
        return Column(
          key: const ValueKey('loaded'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.status == WeatherStatus.refreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.white54,
                  minHeight: 2,
                ),
              ),
            if (provider.isOfflineData)
              _OfflineBanner(lastUpdated: provider.lastUpdated),
            WeatherCard(weather: weather),
            const SizedBox(height: 14),
            WeatherDetailsCard(weather: weather),
            const SizedBox(height: 14),
            SunPathWidget(weather: weather),
            const SizedBox(height: 14),
            TemperatureChartWidget(hourlyData: forecast.hourly),
            const SizedBox(height: 14),
            WeatherInsightsWidget(weather: weather, forecast: forecast),
            const SizedBox(height: 14),
            if (forecast.hourly.isNotEmpty) ...[
              HourlyForecastCard(items: forecast.hourly),
              const SizedBox(height: 14),
            ],
            if (forecast.daily.isNotEmpty)
              DailyForecastCard(days: forecast.daily),
          ],
        );
    }
  }
}


class _DesktopLayout extends StatelessWidget {
  final WeatherProvider weatherProvider;
  final ThemeProvider themeProvider;
  final TextEditingController searchController;
  final bool isLocating;
  final ValueChanged<String> onSearchChanged;
  final void Function(String) onSearchSubmitted;
  final VoidCallback onClear;
  final VoidCallback onLocationTap;
  final void Function(LocationResult) onSelectLocation;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  const _DesktopLayout({
    required this.weatherProvider,
    required this.themeProvider,
    required this.searchController,
    required this.isLocating,
    required this.onSearchChanged,
    required this.onSearchSubmitted,
    required this.onClear,
    required this.onLocationTap,
    required this.onSelectLocation,
    required this.onRetry,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.isDarkMode;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          children: [
            _Header(isDark: isDark, onThemeToggle: themeProvider.toggleTheme),
            const SizedBox(height: 20),
            _SearchSection(
              controller: searchController,
              provider: weatherProvider,
              isLocating: isLocating,
              onChanged: onSearchChanged,
              onSubmitted: onSearchSubmitted,
              onClear: onClear,
              onLocationTap: onLocationTap,
              onSelect: onSelectLocation,
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildBody(weatherProvider, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(WeatherProvider provider, bool isDark) {
    switch (provider.status) {
      case WeatherStatus.initial:
        return const EmptyStateWidget(key: ValueKey('empty'));
      case WeatherStatus.locating:
      case WeatherStatus.loading:
        return const LoadingShimmer(key: ValueKey('loading'));
      case WeatherStatus.error:
        return ErrorStateWidget(
          key: const ValueKey('error'),
          message: provider.errorMessage ?? 'An error occurred.',
          errorType: provider.errorType,
          onRetry: onRetry,
          onSearchManually: onClear,
          onOpenSettings: provider.errorType == WeatherErrorType.locationError
              ? onOpenSettings
              : null,
        );
      case WeatherStatus.loaded:
      case WeatherStatus.refreshing:
        final weather = provider.weather!;
        final forecast = provider.forecast!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.status == WeatherStatus.refreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: Colors.white54,
                  minHeight: 2,
                ),
              ),
            if (provider.isOfflineData)
              _OfflineBanner(lastUpdated: provider.lastUpdated),
            Row(
              key: const ValueKey('loaded'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      WeatherCard(weather: weather),
                      const SizedBox(height: 14),
                      TemperatureChartWidget(hourlyData: forecast.hourly),
                      const SizedBox(height: 14),
                      if (forecast.hourly.isNotEmpty)
                        HourlyForecastCard(items: forecast.hourly),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      WeatherDetailsCard(weather: weather),
                      const SizedBox(height: 14),
                      SunPathWidget(weather: weather),
                      const SizedBox(height: 14),
                      WeatherInsightsWidget(
                        weather: weather,
                        forecast: forecast,
                      ),
                      const SizedBox(height: 14),
                      if (forecast.daily.isNotEmpty)
                        DailyForecastCard(days: forecast.daily),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}

class _OfflineBanner extends StatelessWidget {
  final DateTime? lastUpdated;
  const _OfflineBanner({required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    if (lastUpdated == null) return const SizedBox.shrink();
    final diff = DateTime.now().difference(lastUpdated!);
    String timeStr;
    if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes} mins ago';
    } else {
      timeStr = '${diff.inHours} hours ago';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, size: 16, color: Colors.orange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Offline Data • Last updated $timeStr',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
