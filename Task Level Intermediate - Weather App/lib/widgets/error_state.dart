import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final WeatherErrorType? errorType;
  final LocationErrorType? locationErrorType;
  final VoidCallback onRetry;
  final VoidCallback? onSearchManually;
  final VoidCallback? onOpenSettings;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
    this.errorType,
    this.locationErrorType,
    this.onSearchManually,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);

    final (IconData icon, String title, Color iconBg) = _resolveDisplay();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: isDark ? 0.15 : 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: iconBg),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _ActionButton(
                  label: 'Retry',
                  icon: Icons.refresh_rounded,
                  onTap: onRetry,
                  primary: true,
                ),
                if (onSearchManually != null)
                  _ActionButton(
                    label: 'Search City',
                    icon: Icons.search_rounded,
                    onTap: onSearchManually!,
                    primary: false,
                  ),
                if (onOpenSettings != null)
                  _ActionButton(
                    label: 'App Settings',
                    icon: Icons.settings_rounded,
                    onTap: onOpenSettings!,
                    primary: false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  (IconData, String, Color) _resolveDisplay() {
    if (locationErrorType != null) {
      return switch (locationErrorType!) {
        LocationErrorType.serviceDisabled => (
          Icons.location_disabled_rounded,
          'Location Disabled',
          Colors.orange,
        ),
        LocationErrorType.permissionDenied => (
          Icons.location_off_rounded,
          'Location Permission Denied',
          Colors.orange,
        ),
        LocationErrorType.permissionPermanentlyDenied => (
          Icons.gpp_bad_rounded,
          'Permission Permanently Denied',
          Colors.red,
        ),
        LocationErrorType.timeout => (
          Icons.timer_off_rounded,
          'Location Timeout',
          Colors.orange,
        ),
        LocationErrorType.unsupported => (
          Icons.location_searching_rounded,
          'Location Unavailable',
          Colors.blueGrey,
        ),
        LocationErrorType.unavailable => (
          Icons.location_searching_rounded,
          'Location Unavailable',
          Colors.orange,
        ),
      };
    }

    if (errorType != null) {
      return switch (errorType!) {
        WeatherErrorType.noInternet => (
          Icons.wifi_off_rounded,
          'No Internet Connection',
          Colors.redAccent,
        ),
        WeatherErrorType.timeout => (
          Icons.timer_off_rounded,
          'Request Timed Out',
          Colors.orange,
        ),
        WeatherErrorType.noResults => (
          Icons.search_off_rounded,
          'No Results Found',
          Colors.blueGrey,
        ),
        WeatherErrorType.locationError => (
          Icons.location_off_rounded,
          'Location Error',
          Colors.orange,
        ),
        WeatherErrorType.serverError => (
          Icons.cloud_off_rounded,
          'Server Error',
          Colors.redAccent,
        ),
        WeatherErrorType.parseError => (
          Icons.broken_image_rounded,
          'Data Error',
          Colors.redAccent,
        ),
        _ => (
          Icons.cloud_off_rounded,
          'Something Went Wrong',
          Colors.redAccent,
        ),
      };
    }

    return (Icons.cloud_off_rounded, 'Something Went Wrong', Colors.redAccent);
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    if (primary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withValues(alpha: 0.85),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
    }
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
