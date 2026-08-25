import 'package:activity_tracker/main.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_database_service.dart';
import 'support/fake_goal_service.dart';

void main() {
  testWidgets('shows the onboarding screen when there is no active goal',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalServiceProvider.overrideWithValue(FakeGoalService()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Créer mon défi'), findsOneWidget);
  });

  testWidgets('shows the dashboard when an active goal exists',
      (WidgetTester tester) async {
    final Goal goal = Goal(
      id: 1,
      targetKm: 100,
      targetDate: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalServiceProvider
              .overrideWithValue(FakeGoalService(initialGoal: goal)),
          databaseServiceProvider.overrideWithValue(FakeDatabaseService()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mon défi'), findsOneWidget);
  });
}
