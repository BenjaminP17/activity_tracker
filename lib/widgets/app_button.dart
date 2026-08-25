import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, outline }

enum AppButtonSize { small, medium, large }

/// A reusable button matching the app's design system: no shadow, a smooth
/// enabled/disabled transition, and a loading spinner state.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;

  bool get _isTappable => onPressed != null && !isLoading;

  double get _verticalPadding => switch (size) {
        AppButtonSize.small => 8,
        AppButtonSize.medium => 12,
        AppButtonSize.large => 16,
      };

  double get _fontSize => switch (size) {
        AppButtonSize.small => 12,
        AppButtonSize.medium => 14,
        AppButtonSize.large => 16,
      };

  Color get _backgroundColor => switch (variant) {
        AppButtonVariant.primary => AppColors.primary,
        AppButtonVariant.secondary => AppColors.border,
        AppButtonVariant.outline => Colors.transparent,
      };

  Color get _foregroundColor => switch (variant) {
        AppButtonVariant.primary => AppColors.background,
        AppButtonVariant.secondary => AppColors.text,
        AppButtonVariant.outline => AppColors.text,
      };

  BorderSide get _borderSide => variant == AppButtonVariant.outline
      ? const BorderSide(color: AppColors.border)
      : BorderSide.none;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: onPressed == null ? 0.5 : 1,
      child: Material(
        color: _backgroundColor,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: _borderSide,
        ),
        child: InkWell(
          onTap: _isTappable ? onPressed : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _verticalPadding * 2,
              vertical: _verticalPadding,
            ),
            child: isLoading
                ? SizedBox(
                    width: _fontSize,
                    height: _fontSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _foregroundColor,
                    ),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: _foregroundColor,
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
