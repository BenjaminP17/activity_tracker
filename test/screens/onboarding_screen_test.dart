import 'package:activity_tracker/providers/providers.dart';
import 'package:activity_tracker/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../support/fake_goal_service.dart';

void main() {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

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

  /// Taps the date field (opens the Material date picker triggered by
  /// [showDatePicker]), selects [day] of the month currently displayed by
  /// the calendar, and confirms.
  Future<void> pickDay(WidgetTester tester, int day) async {
    final Finder dateField = find.byType(TextField).at(1);
    await tester.tap(dateField);
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);

    await tester.tap(
      find
          .descendant(
            of: find.byType(CalendarDatePicker),
            matching: find.text('$day'),
          )
          .first,
    );
    await tester.pumpAndSettle();

    final String okLabel = MaterialLocalizations.of(
      tester.element(find.byType(CalendarDatePicker)),
    ).okButtonLabel;
    await tester.tap(find.text(okLabel));
    await tester.pumpAndSettle();
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
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.descendant(
        of: textFields.at(0),
        matching: find.byType(EditableText),
      )).controller.text,
      '500',
    );
  });

  testWidgets('tapping the date field opens the date picker',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets('picking a date fills the field with the JJ/MM/AAAA format',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    await pickDay(tester, tomorrow.day);

    expect(find.text(dateFormat.format(tomorrow)), findsOneWidget);
  });

  testWidgets('tapping "Créer le défi" with valid input calls the goal service',
      (WidgetTester tester) async {
    final FakeGoalService fakeService = await pumpScreen(tester);

    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    final DateTime tomorrowDateOnly =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day);

    await tester.enterText(find.byType(TextField).at(0), '250');
    await pickDay(tester, tomorrow.day);

    await tester.tap(find.text('Créer le défi'));
    await tester.pumpAndSettle();

    expect(fakeService.insertedGoal, isNotNull);
    expect(fakeService.insertedGoal!.targetKm, 250);
    expect(fakeService.insertedGoal!.targetDate, tomorrowDateOnly);
    expect(fakeService.insertedGoal!.isActive, isTrue);
  });

  testWidgets('shows a validation error when km is not greater than 0',
      (WidgetTester tester) async {
    final FakeGoalService fakeService = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '0');
    await pickDay(tester, DateTime.now().add(const Duration(days: 1)).day);

    await tester.tap(find.text('Créer le défi'));
    await tester.pump();

    expect(find.text('Entre un nombre de km supérieur à 0'), findsOneWidget);
    expect(fakeService.insertedGoal, isNull);
  });

  testWidgets('shows a validation error when no date has been selected',
      (WidgetTester tester) async {
    final FakeGoalService fakeService = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '100');
    await tester.pump();

    await tester.tap(find.text('Créer le défi'));
    await tester.pump();

    expect(find.text('Sélectionne une date'), findsOneWidget);
    expect(fakeService.insertedGoal, isNull);
  });
}
