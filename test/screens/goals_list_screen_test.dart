import 'package:activity_tracker/models/activity_type.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/providers/providers.dart';
import 'package:activity_tracker/screens/dashboard_screen.dart';
import 'package:activity_tracker/screens/goals_list_screen.dart';
import 'package:activity_tracker/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_database_service.dart';
import '../support/fake_goal_service.dart';

void main() {
  Goal buildGoal({
    required int id,
    required String name,
    required double targetKm,
    required DateTime targetDate,
    bool isActive = false,
  }) =>
      Goal(
        id: id,
        name: name,
        targetKm: targetKm,
        targetDate: targetDate,
        activityType: ActivityType.running,
        isActive: isActive,
        createdAt: DateTime.now(),
      );

  /// Pumps a host screen with a button that pushes [GoalsListScreen],
  /// mirroring how the dashboard opens it, so popping on selection has
  /// somewhere to return to.
  Future<FakeGoalService> pumpScreen(
    WidgetTester tester, {
    required List<Goal> goals,
    List<RunEntry> runs = const [],
  }) async {
    final FakeGoalService fakeGoalService =
        FakeGoalService(initialGoals: goals);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalServiceProvider.overrideWithValue(fakeGoalService),
          databaseServiceProvider
              .overrideWithValue(FakeDatabaseService(initialRuns: runs)),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const GoalsListScreen(),
                    ),
                  ),
                  child: const Text('Voir mes défis'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Voir mes défis'));
    await tester.pumpAndSettle();
    return fakeGoalService;
  }

  testWidgets('displays ongoing goals sorted by deadline, soonest first',
      (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final Goal far = buildGoal(
      id: 1,
      name: 'Défi lointain',
      targetKm: 200,
      targetDate: now.add(const Duration(days: 60)),
    );
    final Goal near = buildGoal(
      id: 2,
      name: 'Défi proche',
      targetKm: 100,
      targetDate: now.add(const Duration(days: 10)),
    );

    await pumpScreen(
      tester,
      goals: [far, near],
      runs: [RunEntry(id: 1, kilometers: 25, date: now, goalId: 2)],
    );

    expect(find.text('Défi lointain'), findsOneWidget);
    expect(find.text('Défi proche'), findsOneWidget);
    expect(find.text('Running'), findsNWidgets(2));
    expect(find.text('25.0 / 100.0 km'), findsOneWidget);
    expect(find.text('0.0 / 200.0 km'), findsOneWidget);

    // "Défi proche" (soonest deadline) is listed before "Défi lointain".
    final double nearTop = tester.getTopLeft(find.text('Défi proche')).dy;
    final double farTop = tester.getTopLeft(find.text('Défi lointain')).dy;
    expect(nearTop, lessThan(farTop));
  });

  testWidgets('excludes goals whose deadline has already passed',
      (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final Goal past = buildGoal(
      id: 1,
      name: 'Défi terminé',
      targetKm: 50,
      targetDate: now.subtract(const Duration(days: 5)),
    );
    final Goal ongoing = buildGoal(
      id: 2,
      name: 'Défi en cours',
      targetKm: 50,
      targetDate: now.add(const Duration(days: 5)),
    );

    await pumpScreen(tester, goals: [past, ongoing]);

    expect(find.text('Défi terminé'), findsNothing);
    expect(find.text('Défi en cours'), findsOneWidget);
  });

  testWidgets(
      'tapping a card activates that goal and pushes the dashboard on top',
      (WidgetTester tester) async {
    final DateTime now = DateTime.now();
    final Goal first = buildGoal(
      id: 1,
      name: 'Défi A',
      targetKm: 100,
      targetDate: now.add(const Duration(days: 10)),
      isActive: true,
    );
    final Goal second = buildGoal(
      id: 2,
      name: 'Défi B',
      targetKm: 100,
      targetDate: now.add(const Duration(days: 20)),
    );

    final FakeGoalService fakeGoalService =
        await pumpScreen(tester, goals: [first, second]);

    await tester.tap(find.text('Défi B'));
    await tester.pumpAndSettle();

    expect(fakeGoalService.activatedId, 2);
    // The dashboard was pushed on top; the goals list is still beneath it
    // (offstage, since Navigator keeps prior routes mounted).
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(
      find.byType(GoalsListScreen, skipOffstage: false),
      findsOneWidget,
    );

    // The system/swipe back gesture pops the dashboard and returns here.
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsNothing);
    expect(find.byType(GoalsListScreen), findsOneWidget);
  });

  testWidgets('the FAB opens the onboarding screen to create a new goal',
      (WidgetTester tester) async {
    await pumpScreen(tester, goals: []);

    await tester.tap(find.text('Créer un défi'));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
