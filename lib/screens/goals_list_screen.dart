import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/activity_type.dart';
import '../models/goal.dart';
import '../models/run_entry.dart';
import '../providers/goal_provider.dart';
import '../providers/run_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';

/// Lists every challenge whose deadline hasn't passed yet, soonest first.
/// Tapping a card makes that challenge the active one and pushes the
/// dashboard on top of this screen, so the system/swipe back gesture
/// returns here automatically.
class GoalsListScreen extends ConsumerWidget {
  const GoalsListScreen({super.key});

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selectGoal(
    BuildContext context,
    WidgetRef ref,
    int id,
  ) async {
    await ref.read(goalServiceProvider).setActive(id);
    await ref.read(currentGoalProvider.notifier).refresh();
    await ref.read(goalListProvider.notifier).refresh();

    if (!context.mounted) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
    );
  }

  void _openDashboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
    );
  }

  void _openOnboarding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OnboardingScreen()),
    );
  }

  List<Goal> _ongoingGoals(List<Goal> goals) {
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    final List<Goal> ongoing = goals
        .where((Goal goal) => goal.targetDate.isAfter(todayDateOnly))
        .toList()
      ..sort((Goal a, Goal b) => a.targetDate.compareTo(b.targetDate));
    return ongoing;
  }

  double _totalKmFor(Goal goal, List<RunEntry> runs) {
    return runs
        .where((RunEntry run) => run.goalId == goal.id)
        .fold(0.0, (double sum, RunEntry run) => sum + run.kilometers);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Goal>> goalsAsync = ref.watch(goalListProvider);
    final AsyncValue<List<RunEntry>> runsAsync = ref.watch(runListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes défis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard_outlined),
            tooltip: 'Tableau de bord',
            onPressed: () => _openDashboard(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openOnboarding(context),
        icon: const Icon(Icons.add),
        label: const Text('Créer un défi'),
      ),
      body: goalsAsync.when(
        data: (List<Goal> goals) {
          final List<RunEntry> runs = runsAsync.valueOrNull ?? const [];
          final List<Goal> ongoing = _ongoingGoals(goals);

          if (ongoing.isEmpty) {
            return const Center(
              child: Text(
                'Aucun défi en cours',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: ongoing.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (BuildContext context, int index) {
              final Goal goal = ongoing[index];
              final double totalKm = _totalKmFor(goal, runs);
              return _GoalCard(
                goal: goal,
                totalKm: totalKm,
                dateFormat: _dateFormat,
                onTap: () => _selectGoal(context, ref, goal.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('Une erreur est survenue: $error')),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
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
            '${dateFormat.format(goal.targetDate)} · $_daysRemaining jours restants',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
