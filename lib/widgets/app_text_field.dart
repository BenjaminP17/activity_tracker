import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A reusable text field matching the app's design system: an underline
/// style with rounded top corners, and consistent focus/error/disabled
/// colors.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.icon,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.onChanged,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final IconData? icon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  static const BorderRadius _borderRadius =
      BorderRadius.vertical(top: Radius.circular(8));

  UnderlineInputBorder _borderWith(Color color, {double width = 1}) {
    return UnderlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: onTap != null,
      showCursor: onTap == null,
      mouseCursor: onTap == null ? null : SystemMouseCursors.click,
      style: const TextStyle(fontSize: 14, color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        prefixIcon:
            icon == null ? null : Icon(icon, color: AppColors.textSecondary),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: _borderWith(AppColors.border),
        enabledBorder: _borderWith(AppColors.border),
        disabledBorder: _borderWith(AppColors.border.withValues(alpha: 0.5)),
        focusedBorder: _borderWith(AppColors.primary, width: 2),
        errorBorder: _borderWith(AppColors.error),
        focusedErrorBorder: _borderWith(AppColors.error, width: 2),
      ),
    );
  }
}
