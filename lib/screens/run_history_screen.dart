import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../models/run_entry.dart';
import '../providers/goal_provider.dart';
import '../providers/run_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_card.dart';

/// Lists every run logged against the active goal, most recent first.
class RunHistoryScreen extends ConsumerWidget {
  const RunHistoryScreen({super.key});

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  /// Asks for confirmation, then deletes [run] from the active goal.
  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    RunEntry run,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Supprimer la course'),
        content: Text(
          'Supprimer la course du ${_dateFormat.format(run.date)} '
          '(${run.kilometers.toStringAsFixed(1)} km) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    await ref.read(runDeleteProvider.notifier).delete(run.id);
  }

  /// Runs belonging to [goal], most recent date first.
  List<RunEntry> _sortedRunsForGoal(List<RunEntry> runs, Goal? goal) {
    if (goal == null) {
      return const [];
    }
    final List<RunEntry> forGoal =
        runs.where((RunEntry run) => run.goalId == goal.id).toList();
    forGoal.sort((RunEntry a, RunEntry b) => b.date.compareTo(a.date));
    return forGoal;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<Goal?> goalAsync = ref.watch(currentGoalProvider);
    final AsyncValue<List<RunEntry>> runsAsync = ref.watch(runListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: runsAsync.when(
        data: (List<RunEntry> runs) {
          final List<RunEntry> sorted =
              _sortedRunsForGoal(runs, goalAsync.valueOrNull);

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historique des courses',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: sorted.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucune course enregistrée',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: sorted.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (BuildContext context, int index) {
                            final RunEntry run = sorted[index];
                            return _RunCard(
                              run: run,
                              dateFormat: _dateFormat,
                              onLongPress: () =>
                                  _confirmAndDelete(context, ref, run),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('Une erreur est survenue: $error')),
      ),
    );
  }
}

class _RunCard extends StatelessWidget {
  const _RunCard({
    required this.run,
    required this.dateFormat,
    required this.onLongPress,
  });

  final RunEntry run;
  final DateFormat dateFormat;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final String? notes = run.notes;
    final bool hasNotes = notes != null && notes.isNotEmpty;

    return AppCard(
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(run.date),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                '${run.kilometers.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (hasNotes) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              notes,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
