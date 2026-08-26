import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/goal.dart';
import '../models/run_entry.dart';
import '../providers/goal_provider.dart';
import '../providers/run_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

/// Screen used to log a new run: distance, date and optional notes, saved
/// against the currently active goal.
class AddRunScreen extends ConsumerStatefulWidget {
  const AddRunScreen({super.key});

  @override
  ConsumerState<AddRunScreen> createState() => _AddRunScreenState();
}

class _AddRunScreenState extends ConsumerState<AddRunScreen> {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedDate;
  String? _kmError;
  String? _dateError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _kmController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double? _parseKm() => double.tryParse(_kmController.text.trim());

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
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
    final double? km = _parseKm();
    final DateTime? date = _selectedDate;
    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    setState(() {
      _kmError =
          (km == null || km <= 0) ? 'Entre un nombre de km supérieur à 0' : null;
      _dateError = date == null
          ? 'Sélectionne une date'
          : (date.isAfter(todayDateOnly)
              ? 'La date ne peut pas être dans le futur'
              : null);
    });

    return _kmError == null && _dateError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final Goal? goal = await ref.read(currentGoalProvider.future);
    if (!mounted) {
      return;
    }
    final String notes = _notesController.text.trim();
    final RunEntry run = RunEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      kilometers: _parseKm()!,
      date: _selectedDate!,
      notes: notes.isEmpty ? null : notes,
      goalId: goal?.id,
    );

    await ref.read(runInsertProvider.notifier).insert(run);

    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = false);

    final Object? error = ref.read(runInsertProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue, réessaie.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activité enregistrée avec succès !')),
    );
    Navigator.of(context).pop();
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
                'Enregistrer une activité',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                "Ajoute ta course d'aujourd'hui",
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _kmController,
                label: 'Distance (km)',
                hintText: '10.5',
                errorText: _kmError,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _dateController,
                label: 'Date',
                hintText: 'JJ/MM/AAAA',
                errorText: _dateError,
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _notesController,
                label: 'Notes',
                hintText: 'Notes (optionnel)',
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Enregistrer',
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
