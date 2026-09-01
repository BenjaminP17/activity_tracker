import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/activity_type.dart';
import '../models/goal.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'app_card.dart';

/// A card summarizing a single [Goal]'s progress (while active) or its
/// final status (once finalized).
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.totalKm,
    required this.dateFormat,
    required this.onTap,
  });

  final Goal goal;
  final double totalKm;
  final DateFormat dateFormat;
  final VoidCallback onTap;

  double get _progress =>
      goal.targetKm <= 0 ? 0 : (totalKm / goal.targetKm).clamp(0, 1);

  int get _daysRemaining {
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);
    final DateTime target =
        DateTime(goal.targetDate.year, goal.targetDate.month, goal.targetDate.day);
    return target.difference(todayDateOnly).inDays;
  }

  bool get _isFinalized => goal.completionStatus != GoalCompletionStatus.active;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (_isFinalized)
                Text(
                  goal.completionStatus.toLabel(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              goal.activityType.toIcon(),
              const SizedBox(width: AppSpacing.xs),
              Text(
                goal.activityType.toLabel(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${totalKm.toStringAsFixed(1)} / ${goal.targetKm.toStringAsFixed(1)} km',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isFinalized
                ? dateFormat.format(goal.targetDate)
                : '${dateFormat.format(goal.targetDate)} · $_daysRemaining jours restants',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
