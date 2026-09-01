import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../models/run_entry.dart';
import '../providers/goal_provider.dart';
import '../providers/run_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/goal_card.dart';
import 'dashboard_screen.dart';
import 'onboarding_screen.dart';

/// Lists the user's challenges, filtered to either the ones still in
/// progress or the ones already finished. Tapping an in-progress card makes
/// that challenge the active one and pushes the dashboard on top of this
/// screen; tapping a finished one shows its final stats.
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
    await ref.read(activeGoalsProvider.notifier).refresh();

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

  double _totalKmFor(Goal goal, List<RunEntry> runs) {
    return runs
        .where((RunEntry run) => run.goalId == goal.id)
        .fold(0.0, (double sum, RunEntry run) => sum + run.kilometers);
  }

  void _showFinalStats(BuildContext context, Goal goal, List<RunEntry> runs) {
    final List<RunEntry> goalRuns =
        runs.where((RunEntry run) => run.goalId == goal.id).toList();
    final double totalKm =
        goalRuns.fold(0.0, (double sum, RunEntry run) => sum + run.kilometers);
    final DateTime? completedAt = goal.completedAt;
    final int durationDays =
        completedAt == null ? 0 : completedAt.difference(goal.createdAt).inDays;

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text(goal.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.completionStatus.toLabel()),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${totalKm.toStringAsFixed(1)} / ${goal.targetKm.toStringAsFixed(1)} km',
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Durée : $durationDays jours'),
            const SizedBox(height: AppSpacing.xs),
            Text('Nombre de courses : ${goalRuns.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoalFilter filter = ref.watch(goalFilterProvider);
    final bool showCompleted = filter == GoalFilter.completed;
    final AsyncValue<List<Goal>> goalsAsync =
        showCompleted ? ref.watch(completedGoalsProvider) : ref.watch(activeGoalsProvider);
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FilterButton(
                    label: 'En cours',
                    selected: !showCompleted,
                    onTap: () => ref.read(goalFilterProvider.notifier).state =
                        GoalFilter.active,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _FilterButton(
                    label: 'Terminé',
                    selected: showCompleted,
                    onTap: () => ref.read(goalFilterProvider.notifier).state =
                        GoalFilter.completed,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: goalsAsync.when(
              data: (List<Goal> goals) {
                final List<RunEntry> runs = runsAsync.valueOrNull ?? const [];

                if (goals.isEmpty) {
                  return Center(
                    child: Text(
                      showCompleted ? 'Aucun défi terminé' : 'Aucun défi en cours',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: goals.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (BuildContext context, int index) {
                    final Goal goal = goals[index];
                    final double totalKm = _totalKmFor(goal, runs);
                    return GoalCard(
                      goal: goal,
                      totalKm: totalKm,
                      dateFormat: _dateFormat,
                      onTap: showCompleted
                          ? () => _showFinalStats(context, goal, runs)
                          : () => _selectGoal(context, ref, goal.id),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object error, StackTrace stackTrace) =>
                  Center(child: Text('Une erreur est survenue: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
