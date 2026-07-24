// custom_textfield.dart
// ────────────────────────────────────────────────────────────────
// Liquid-glass styled TextFormField.
// Uses a semi-transparent frosted container as the field background.
// Wires all event listeners: onChanged, onEditingComplete, onFieldSubmitted.
// ────────────────────────────────────────────────────────────────

import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.focusNode,
    this.nextFocusNode,
    this.validator,
    this.isPassword = false,
    this.textInputAction = TextInputAction.next,
    this.keyboardType,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    // EVENT LISTENER: react to focus changes for border animation
    widget.focusNode?.addListener(_onFocusChanged);
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() => _hasFocus = widget.focusNode?.hasFocus ?? false);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;

    // Glass colours shift slightly when focused for visual feedback
    final borderColor = _hasFocus
        ? scheme.primary.withValues(alpha: 0.8)
        : (isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.7));

    final fillColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.5);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppConstants.glassBlur * 0.6,
          sigmaY: AppConstants.glassBlur * 0.6,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(
              color: borderColor,
              width: _hasFocus ? 1.5 : AppConstants.glassBorder,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            validator: widget.validator,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autocorrect: !widget.isPassword,
            enableSuggestions: !widget.isPassword,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
            ),

            onChanged: (value) {
              widget.onChanged?.call(value);
            },

            // EVENT LISTENER: onEditingComplete – advance focus
            onEditingComplete: () {
              if (widget.nextFocusNode != null) {
                FocusScope.of(context).requestFocus(widget.nextFocusNode);
              } else {
                FocusScope.of(context).unfocus();
              }
            },

            // EVENT LISTENER: onFieldSubmitted – IME submit key
            onFieldSubmitted: (value) {
              widget.onFieldSubmitted?.call(value);
            },

            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: TextStyle(
                color: _hasFocus
                    ? scheme.primary
                    : (isDark ? Colors.white60 : Colors.black54),
              ),
              hintStyle: TextStyle(
                color: isDark ? Colors.white30 : Colors.black26,
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: _hasFocus
                    ? scheme.primary
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                      tooltip: _obscureText ? 'Show' : 'Hide',
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              // Transparent decoration — the Container above provides the glass
              filled: false,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.error, width: 1.5),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: scheme.error, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium,
                vertical: AppConstants.paddingMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
