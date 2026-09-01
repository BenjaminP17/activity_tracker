import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/goal.dart';
import 'providers/goal_provider.dart';
import 'providers/health_connect_provider.dart';
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
      home: _HealthConnectGate(
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final AsyncValue<Goal?> currentGoal =
                ref.watch(currentGoalProvider);
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
      ),
    );
  }
}

/// Wraps [child] with the Health Connect sync workflow: if already
/// authorized, syncs exercises in the background; otherwise shows a banner
/// prompting the user to activate Health Connect.
class _HealthConnectGate extends ConsumerStatefulWidget {
  const _HealthConnectGate({required this.child});

  final Widget child;

  @override
  ConsumerState<_HealthConnectGate> createState() =>
      _HealthConnectGateState();
}

class _HealthConnectGateState extends ConsumerState<_HealthConnectGate> {
  bool _autoSyncTriggered = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual<AsyncValue<bool>>(
      healthConnectAuthorizedProvider,
      (AsyncValue<bool>? previous, AsyncValue<bool> next) {
        if (next.valueOrNull == true && !_autoSyncTriggered) {
          _autoSyncTriggered = true;
          ref.read(syncHealthConnectProvider.notifier).sync();
        }
      },
      fireImmediately: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<bool> authorized =
        ref.watch(healthConnectAuthorizedProvider);

    return Stack(
      children: [
        widget.child,
        if (authorized.valueOrNull == false)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              child: _HealthConnectBanner(
                onActivate: () => ref
                    .read(syncHealthConnectProvider.notifier)
                    .requestPermissionsAndSync(),
              ),
            ),
          ),
      ],
    );
  }
}

class _HealthConnectBanner extends StatelessWidget {
  const _HealthConnectBanner({required this.onActivate});

  final VoidCallback onActivate;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Expanded(
              child: Text('Importez vos courses depuis Health Connect'),
            ),
            TextButton(
              onPressed: onActivate,
              child: const Text('Activer Health Connect'),
            ),
          ],
        ),
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
