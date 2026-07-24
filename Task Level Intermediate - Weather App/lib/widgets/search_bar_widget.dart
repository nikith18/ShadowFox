import 'package:flutter/material.dart';

import '../widgets/settings_sheet.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final void Function(String) onSubmitted;
  final VoidCallback onLocationTap;
  final VoidCallback onClear;
  final bool isLocating;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onLocationTap,
    required this.onClear,
    this.isLocating = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.5);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.7);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: fillColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: widget.controller,
              style: TextStyle(color: textColor, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search city or place...',
                hintStyle: TextStyle(color: textColor.withValues(alpha: 0.4)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: textColor.withValues(alpha: 0.5),
                  size: 20,
                ),
                suffixIcon: widget.controller.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: textColor.withValues(alpha: 0.5),
                          size: 18,
                        ),
                        onPressed: widget.onClear,
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _LocationButton(
          isLocating: widget.isLocating,
          onTap: widget.onLocationTap,
          textColor: textColor,
          fillColor: fillColor,
          borderColor: borderColor,
        ),
        const SizedBox(width: 8),
        _SettingsButton(
          textColor: textColor,
          fillColor: fillColor,
          borderColor: borderColor,
        ),
      ],
    );
  }
}

class _LocationButton extends StatelessWidget {
  final bool isLocating;
  final VoidCallback onTap;
  final Color textColor, fillColor, borderColor;

  const _LocationButton({
    required this.isLocating,
    required this.onTap,
    required this.textColor,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Current Location',
      child: GestureDetector(
        onTap: isLocating ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: isLocating
              ? Padding(
                  padding: const EdgeInsets.all(13),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                )
              : Icon(
                  Icons.my_location_rounded,
                  color: textColor.withValues(alpha: 0.7),
                  size: 22,
                ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final Color textColor, fillColor, borderColor;

  const _SettingsButton({
    required this.textColor,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Settings',
      child: GestureDetector(
        onTap: () => showSettingsSheet(context),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            Icons.settings_outlined,
            color: textColor.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
      ),
    );
  }
}
