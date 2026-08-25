import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal.dart';
import '../providers/goal_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Onboarding screen shown when the user has no active goal yet: lets them
/// set a target distance and date to create their first challenge.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  String? _kmError;
  String? _dateError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _kmController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  double? _parseKm() => double.tryParse(_kmController.text.trim());

  DateTime? _parseDate() => DateTime.tryParse(_dateController.text.trim());

  bool _validate() {
    final double? km = _parseKm();
    final DateTime? date = _parseDate();
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    setState(() {
      _kmError =
          (km == null || km <= 0) ? 'Entre un nombre de km supérieur à 0' : null;
      _dateError = date == null
          ? 'Entre une date valide (AAAA-MM-JJ)'
          : (date.isAfter(todayDateOnly)
              ? null
              : 'La date doit être dans le futur');
    });

    return _kmError == null && _dateError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final DateTime now = DateTime.now();
    final Goal goal = Goal(
      id: now.millisecondsSinceEpoch,
      targetKm: _parseKm()!,
      targetDate: _parseDate()!,
      isActive: true,
      createdAt: now,
    );

    await ref.read(goalInsertProvider.notifier).insert(goal);

    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);

    final Object? error = ref.read(goalInsertProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue, réessaie.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Défi créé avec succès !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Créer mon défi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Définis ton objectif de km et la date cible',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _kmController,
                label: 'Objectif (km)',
                hintText: '500',
                errorText: _kmError,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _dateController,
                label: 'Date cible',
                hintText: '2026-12-31',
                errorText: _dateError,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Créer le défi',
                  size: AppButtonSize.large,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
