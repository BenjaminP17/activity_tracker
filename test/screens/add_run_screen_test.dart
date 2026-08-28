import 'package:activity_tracker/models/activity_type.dart';
import 'package:activity_tracker/models/goal.dart';
import 'package:activity_tracker/providers/providers.dart';
import 'package:activity_tracker/screens/add_run_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../support/fake_database_service.dart';
import '../support/fake_goal_service.dart';

void main() {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  Goal buildGoal() => Goal(
        id: 1,
        name: 'Marathon Challenge',
        targetKm: 100,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        activityType: ActivityType.running,
        isActive: true,
        createdAt: DateTime.now(),
      );

  /// Pumps a host screen with a button that pushes [AddRunScreen], mirroring
  /// how the dashboard opens it, so popping on success has somewhere to
  /// return to.
  Future<FakeDatabaseService> pumpScreen(WidgetTester tester) async {
    final FakeDatabaseService fakeService = FakeDatabaseService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(fakeService),
          goalServiceProvider
              .overrideWithValue(FakeGoalService(initialGoal: buildGoal())),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (BuildContext context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AddRunScreen(),
                    ),
                  ),
                  child: const Text('Tableau de bord'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Tableau de bord'));
    await tester.pumpAndSettle();
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

    expect(find.text('Enregistrer une activité'), findsOneWidget);
    expect(find.text("Ajoute ta course d'aujourd'hui"), findsOneWidget);

    final Finder textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(3));

    await tester.enterText(textFields.at(0), '10.5');
    await tester.enterText(textFields.at(2), 'Belle sortie');
    await tester.pump();

    expect(
      tester.widget<EditableText>(find.descendant(
        of: textFields.at(0),
        matching: find.byType(EditableText),
      )).controller.text,
      '10.5',
    );
    expect(
      tester.widget<EditableText>(find.descendant(
        of: textFields.at(2),
        matching: find.byType(EditableText),
      )).controller.text,
      'Belle sortie',
    );
  });

  testWidgets('tapping the date field opens the date picker',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(TextField).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(CalendarDatePicker), findsOneWidget);
  });

  testWidgets(
      'picking a date fills the field with the JJ/MM/AAAA format',
      (WidgetTester tester) async {
    await pumpScreen(tester);

    final DateTime today = DateTime.now();
    await pickDay(tester, today.day);

    expect(find.text(dateFormat.format(today)), findsOneWidget);
  });

  testWidgets(
      'tapping "Enregistrer" with valid input calls the run service and '
      'returns to the previous screen',
      (WidgetTester tester) async {
    final FakeDatabaseService fakeService = await pumpScreen(tester);

    final DateTime today = DateTime.now();
    final DateTime todayDateOnly = DateTime(today.year, today.month, today.day);

    await tester.enterText(find.byType(TextField).at(0), '10.5');
    await pickDay(tester, today.day);

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(fakeService.insertedRun, isNotNull);
    expect(fakeService.insertedRun!.kilometers, 10.5);
    expect(fakeService.insertedRun!.date, todayDateOnly);
    expect(fakeService.insertedRun!.goalId, 1);

    // Popped back to the host screen.
    expect(find.byType(AddRunScreen), findsNothing);
  });

  testWidgets('shows a validation error when distance is not greater than 0',
      (WidgetTester tester) async {
    final FakeDatabaseService fakeService = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '0');
    await pickDay(tester, DateTime.now().day);

    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(find.text('Entre un nombre de km supérieur à 0'), findsOneWidget);
    expect(fakeService.insertedRun, isNull);
  });

  testWidgets('shows a validation error when no date has been selected',
      (WidgetTester tester) async {
    final FakeDatabaseService fakeService = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.pump();

    await tester.tap(find.text('Enregistrer'));
    await tester.pump();

    expect(find.text('Sélectionne une date'), findsOneWidget);
    expect(fakeService.insertedRun, isNull);
  });
}
