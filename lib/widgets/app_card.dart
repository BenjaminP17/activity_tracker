import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// A reusable card matching the app's design system: surface background,
/// a subtle shadow, and an opacity dip on touch when [onTap] is set.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isTappable = widget.onTap != null;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: isTappable ? (_) => _setPressed(true) : null,
      onTapUp: isTappable ? (_) => _setPressed(false) : null,
      onTapCancel: isTappable ? () => _setPressed(false) : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: _isPressed ? 0.6 : 1,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
