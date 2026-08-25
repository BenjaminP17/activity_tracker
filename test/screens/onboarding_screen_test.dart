import 'package:activity_tracker/providers/providers.dart';
import 'package:activity_tracker/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_goal_service.dart';

void main() {
  Future<FakeGoalService> pumpScreen(WidgetTester tester) async {
    final FakeGoalService fakeService = FakeGoalService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [goalServiceProvider.overrideWithValue(fakeService)],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    return fakeService;
  }

  testWidgets('renders the title, subtitle and fillable fields',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    expect(find.text('Créer mon défi'), findsOneWidget);
    expect(
      find.text('Définis ton objectif de km et la date cible'),
      findsOneWidget,
    );

    final Finder textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), '500');
    await tester.enterText(textFields.at(1), '2026-12-31');
    await tester.pump();

    final List<EditableText> editableTexts =
        tester.widgetList<EditableText>(find.byType(EditableText)).toList();

    expect(editableTexts[0].controller.text, '500');
    expect(editableTexts[1].controller.text, '2026-12-31');
  });

  testWidgets('tapping "Créer le défi" with valid input calls the goal service',
      (WidgetTester tester) async {
    final FakeGoalService fakeService = await pumpScreen(tester);

    final Finder textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '250');
    await tester.enterText(textFields.at(1), '2026-12-31');
    await tester.pump();

    await tester.tap(find.text('Créer le défi'));
    await tester.pumpAndSettle();

    expect(fakeService.insertedGoal, isNotNull);
    expect(fakeService.insertedGoal!.targetKm, 250);
    expect(fakeService.insertedGoal!.targetDate, DateTime.parse('2026-12-31'));
    expect(fakeService.insertedGoal!.isActive, isTrue);
  });

  testWidgets('shows a validation error when km is not greater than 0',
      (WidgetTester tester) async {
    final FakeGoalService fakeService = await pumpScreen(tester);

    final Finder textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '0');
    await tester.enterText(textFields.at(1), '2026-12-31');
    await tester.pump();

    await tester.tap(find.text('Créer le défi'));
    await tester.pump();

    expect(find.text('Entre un nombre de km supérieur à 0'), findsOneWidget);
    expect(fakeService.insertedGoal, isNull);
  });

  testWidgets('shows a validation error when the date is not in the future',
      (WidgetTester tester) async {
    final FakeGoalService fakeService = await pumpScreen(tester);

    final Finder textFields = find.byType(TextField);
    await tester.enterText(textFields.at(0), '100');
    await tester.enterText(textFields.at(1), '2020-01-01');
    await tester.pump();

    await tester.tap(find.text('Créer le défi'));
    await tester.pump();

    expect(find.text('La date doit être dans le futur'), findsOneWidget);
    expect(fakeService.insertedGoal, isNull);
  });
}
