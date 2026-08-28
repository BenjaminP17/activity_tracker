import 'package:activity_tracker/models/activity_type.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/models/run_entry.dart';
import 'package:activity_tracker/providers/providers.dart';
import 'package:activity_tracker/screens/run_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../support/fake_database_service.dart';
import '../support/fake_goal_service.dart';

void main() {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  Goal buildActiveGoal({int id = 1}) => Goal(
        id: id,
        name: 'Marathon Challenge',
        targetKm: 100,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        activityType: ActivityType.running,
        isActive: true,
        createdAt: DateTime.now(),
      );

  /// Pumps a host screen with a button that pushes [RunHistoryScreen],
  /// mirroring how the dashboard opens it, so popping via the back button
  /// has somewhere to return to.
  Future<void> pumpScreen(
    WidgetTester tester, {
    Goal? activeGoal,
    List<RunEntry> runs = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalServiceProvider
              .overrideWithValue(FakeGoalService(initialGoal: activeGoal)),
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
                      builder: (_) => const RunHistoryScreen(),
                    ),
                  ),
                  child: const Text("Voir l'historique"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text("Voir l'historique"));
    await tester.pumpAndSettle();
  }

  testWidgets('displays the title', (WidgetTester tester) async {
    await pumpScreen(tester, activeGoal: buildActiveGoal());

    expect(find.text('Historique des courses'), findsOneWidget);
  });

  testWidgets('displays runs sorted by date, most recent first',
      (WidgetTester tester) async {
    final Goal goal = buildActiveGoal();
    final DateTime now = DateTime.now();
    final RunEntry oldest = RunEntry(
      id: 1,
      kilometers: 5,
      date: now.subtract(const Duration(days: 10)),
      goalId: goal.id,
    );
    final RunEntry newest = RunEntry(
      id: 2,
      kilometers: 8,
      date: now,
      goalId: goal.id,
    );
    final RunEntry middle = RunEntry(
      id: 3,
      kilometers: 10.5,
      date: now.subtract(const Duration(days: 5)),
      goalId: goal.id,
    );

    await pumpScreen(
      tester,
      activeGoal: goal,
      runs: [oldest, newest, middle],
    );

    expect(find.text(dateFormat.format(newest.date)), findsOneWidget);
    expect(find.text(dateFormat.format(middle.date)), findsOneWidget);
    expect(find.text(dateFormat.format(oldest.date)), findsOneWidget);
    expect(find.text('10.5 km'), findsOneWidget);

    final double newestTop =
        tester.getTopLeft(find.text(dateFormat.format(newest.date))).dy;
    final double middleTop =
        tester.getTopLeft(find.text(dateFormat.format(middle.date))).dy;
    final double oldestTop =
        tester.getTopLeft(find.text(dateFormat.format(oldest.date))).dy;

    expect(newestTop, lessThan(middleTop));
    expect(middleTop, lessThan(oldestTop));
  });

  testWidgets('displays notes when present, and omits them when absent',
      (WidgetTester tester) async {
    final Goal goal = buildActiveGoal();
    final DateTime now = DateTime.now();
    final RunEntry withNotes = RunEntry(
      id: 1,
      kilometers: 5,
      date: now,
      goalId: goal.id,
      notes: 'Belle sortie',
    );
    final RunEntry withoutNotes = RunEntry(
      id: 2,
      kilometers: 6,
      date: now.subtract(const Duration(days: 1)),
      goalId: goal.id,
    );

    await pumpScreen(
      tester,
      activeGoal: goal,
      runs: [withNotes, withoutNotes],
    );

    expect(find.text('Belle sortie'), findsOneWidget);
  });

  testWidgets('shows a message when there are no runs',
      (WidgetTester tester) async {
    await pumpScreen(tester, activeGoal: buildActiveGoal());

    expect(find.text('Aucune course enregistrée'), findsOneWidget);
  });

  testWidgets('the back button returns to the previous screen',
      (WidgetTester tester) async {
    await pumpScreen(tester, activeGoal: buildActiveGoal());

    expect(find.byType(RunHistoryScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(RunHistoryScreen), findsNothing);
  });
}
