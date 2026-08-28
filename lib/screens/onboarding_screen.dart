import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/activity_type.dart';
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
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final ActivityType _activityType = ActivityType.running;

  DateTime? _selectedDate;
  String? _nameError;
  String? _kmError;
  String? _dateError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _kmController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  double? _parseKm() => double.tryParse(_kmController.text.trim());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = now.add(const Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? tomorrow,
      firstDate: tomorrow,
      lastDate: DateTime(now.year + 10),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = picked;
      _dateController.text = _dateFormat.format(picked);
    });
  }

  bool _validate() {
    final String name = _nameController.text.trim();
    final double? km = _parseKm();
    final DateTime? date = _selectedDate;
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    setState(() {
      _nameError = name.isEmpty ? 'Entre un nom pour ton défi' : null;
      _kmError =
          (km == null || km <= 0) ? 'Entre un nombre de km supérieur à 0' : null;
      _dateError = date == null
          ? 'Sélectionne une date'
          : (date.isAfter(todayDateOnly)
              ? null
              : 'La date doit être dans le futur');
    });

    return _nameError == null && _kmError == null && _dateError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final DateTime now = DateTime.now();
    final Goal goal = Goal(
      id: now.millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      targetKm: _parseKm()!,
      targetDate: _selectedDate!,
      activityType: _activityType,
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
                controller: _nameController,
                label: 'Nom du défi',
                hintText: 'Marathon Challenge',
                errorText: _nameError,
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Type d\'activité',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ChoiceChip(
                avatar: _activityType.toIcon(),
                label: Text(_activityType.toLabel()),
                selected: true,
                onSelected: (_) {},
              ),
              const SizedBox(height: AppSpacing.md),
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
                hintText: 'JJ/MM/AAAA',
                errorText: _dateError,
                onTap: () => _selectDate(context),
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
