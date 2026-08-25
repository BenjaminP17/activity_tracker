import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_text_field.dart';
import '../widgets/stats_card.dart';

/// Showcases every design system component on a single scrollable page.
class ShowcaseScreen extends StatelessWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Design System')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _SectionTitle('Couleurs'),
          _ColorsSection(),
          SizedBox(height: AppSpacing.md),
          _SectionTitle('Boutons'),
          _ButtonsSection(),
          SizedBox(height: AppSpacing.md),
          _SectionTitle('États buttons'),
          _ButtonStatesSection(),
          SizedBox(height: AppSpacing.md),
          _SectionTitle('Cards'),
          _CardsSection(),
          SizedBox(height: AppSpacing.md),
          _SectionTitle('Stats Cards'),
          _StatsCardsSection(),
          SizedBox(height: AppSpacing.md),
          _SectionTitle('Text Fields'),
          _TextFieldsSection(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: const [
        _ColorSwatch('Primary', AppColors.primary),
        _ColorSwatch('Accent', AppColors.accent),
        _ColorSwatch('Background', AppColors.background),
        _ColorSwatch('Surface', AppColors.surface),
        _ColorSwatch('Text', AppColors.text),
        _ColorSwatch('Text Secondary', AppColors.textSecondary),
        _ColorSwatch('Border', AppColors.border),
        _ColorSwatch('Error', AppColors.error),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _ButtonsSection extends StatelessWidget {
  const _ButtonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final AppButtonVariant variant in AppButtonVariant.values) ...[
          Text(
            variant.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final AppButtonSize size in AppButtonSize.values)
                AppButton(
                  label: size.name,
                  variant: variant,
                  size: size,
                  onPressed: () {},
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _ButtonStatesSection extends StatelessWidget {
  const _ButtonStatesSection();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: const [
        AppButton(label: 'Loading', onPressed: null, isLoading: true),
        AppButton(label: 'Disabled', onPressed: null),
      ],
    );
  }
}

class _CardsSection extends StatelessWidget {
  const _CardsSection();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Titre de la card',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Un contenu simple pour illustrer AppCard.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatsCardsSection extends StatelessWidget {
  const _StatsCardsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        StatsCard(
          title: 'Total parcouru',
          value: '128 km',
          subtitle: 'Depuis le début de l\'objectif',
          icon: Icons.route,
        ),
        SizedBox(height: AppSpacing.sm),
        StatsCard(
          title: 'Km restants',
          value: '72 km',
          subtitle: 'Pour atteindre 200 km',
          valueColor: AppColors.primary,
          icon: Icons.flag,
        ),
        SizedBox(height: AppSpacing.sm),
        StatsCard(
          title: 'Moyenne hebdo requise',
          value: '9.2 km',
          subtitle: 'Sur les 8 semaines restantes',
          valueColor: AppColors.accent,
          icon: Icons.trending_up,
        ),
      ],
    );
  }
}

class _TextFieldsSection extends StatelessWidget {
  const _TextFieldsSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AppTextField(
          label: 'Distance',
          hintText: 'Ex: 5.2',
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Date',
          hintText: 'JJ/MM/AAAA',
          icon: Icons.calendar_today,
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Distance',
          errorText: 'Veuillez entrer une valeur valide',
        ),
        SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Champ désactivé',
          hintText: 'Non modifiable',
          enabled: false,
        ),
      ],
    );
  }
}
