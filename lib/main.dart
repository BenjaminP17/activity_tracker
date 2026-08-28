import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/goal.dart';
import 'providers/goal_provider.dart';
import 'screens/goals_list_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Tracker',
      theme: AppTheme.light,
      home: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final AsyncValue<Goal?> currentGoal = ref.watch(currentGoalProvider);
          return currentGoal.when(
            data: (Goal? goal) => goal == null
                ? const OnboardingScreen()
                : const GoalsListScreen(),
            loading: () => const _LoadingScreen(),
            error: (Object error, StackTrace stackTrace) =>
                _ErrorScreen(error: error),
          );
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Une erreur est survenue: $error')),
    );
  }
}
