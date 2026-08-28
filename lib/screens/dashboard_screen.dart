import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_stats.dart';
import '../providers/dashboard_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/stats_card.dart';
import 'add_run_screen.dart';

/// Displays the active goal's progress: total km covered, km remaining, and
/// the weekly average needed to reach the target on time.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<DashboardStats> stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mon défi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AddRunScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une activité'),
      ),
      body: stats.when(
        data: (DashboardStats value) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            StatsCard(
              title: 'Objectif visé',
              value: '${value.targetKm.toStringAsFixed(1)} km',
              icon: Icons.emoji_events,
            ),
            const SizedBox(height: AppSpacing.sm),
            StatsCard(
              title: 'Date limite',
              value: value.targetDate == null
                  ? '—'
                  : _dateFormat.format(value.targetDate!),
              icon: Icons.event,
            ),
            const SizedBox(height: AppSpacing.sm),
            StatsCard(
              title: 'Total parcouru',
              value: '${value.totalKm.toStringAsFixed(1)} km',
              icon: Icons.route,
            ),
            const SizedBox(height: AppSpacing.sm),
            StatsCard(
              title: 'Km restants',
              value: '${value.remainingKm.toStringAsFixed(1)} km',
              valueColor: AppColors.primary,
              icon: Icons.flag,
            ),
            const SizedBox(height: AppSpacing.sm),
            StatsCard(
              title: 'Semaines restantes',
              value: '${value.weeksRemaining}',
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: AppSpacing.sm),
            StatsCard(
              title: 'Moyenne hebdo requise',
              value: '${value.weeklyAverageNeeded.toStringAsFixed(1)} km',
              valueColor: AppColors.accent,
              icon: Icons.trending_up,
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) =>
            Center(child: Text('Une erreur est survenue: $error')),
      ),
    );
  }
}
