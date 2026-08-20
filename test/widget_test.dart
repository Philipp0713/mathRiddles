import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:math_riddle_app/app.dart';

void main() {
  testWidgets('Home screen shows a Play button that opens the level menu', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MathRiddleApp());

    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Choose a Puzzle'), findsNothing);

    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a Puzzle'), findsOneWidget);
    expect(find.text('Addition Riddle'), findsOneWidget);
  });

  testWidgets('Riddle screen keypad fills the answer field and grades it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MathRiddleApp());
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Addition Riddle'));
    await tester.pumpAndSettle();

    final answerField = find.byType(TextField);
    expect(answerField, findsOneWidget);
    expect(tester.widget<TextField>(answerField).controller!.text, isEmpty);

    await tester.tap(find.widgetWithText(OutlinedButton, '9'));
    await tester.tap(find.widgetWithText(OutlinedButton, '9'));
    await tester.pump();
    expect(tester.widget<TextField>(answerField).controller!.text, '99');

    await tester.tap(find.widgetWithText(OutlinedButton, 'C'));
    await tester.pump();
    expect(tester.widget<TextField>(answerField).controller!.text, isEmpty);

    await tester.tap(find.widgetWithText(FilledButton, 'Check'));
    await tester.pump();
    expect(find.text('Enter a number.'), findsOneWidget);
  });

  testWidgets(
    'Answer field accepts negative numbers via keypad and keyboard',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MathRiddleApp());
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Addition Riddle'));
      await tester.pumpAndSettle();

      final answerField = find.byType(TextField);

      // On-screen keypad: digits then the ± toggle.
      await tester.tap(find.widgetWithText(OutlinedButton, '4'));
      await tester.tap(find.widgetWithText(OutlinedButton, '2'));
      await tester.tap(find.widgetWithText(OutlinedButton, '±'));
      await tester.pump();
      expect(tester.widget<TextField>(answerField).controller!.text, '-42');

      // Toggling again flips back to positive.
      await tester.tap(find.widgetWithText(OutlinedButton, '±'));
      await tester.pump();
      expect(tester.widget<TextField>(answerField).controller!.text, '42');

      // Direct keyboard/IME input also accepts a leading minus.
      await tester.enterText(answerField, '-17');
      await tester.pump();
      expect(tester.widget<TextField>(answerField).controller!.text, '-17');

      // A minus anywhere other than the front is rejected.
      await tester.enterText(answerField, '1-7');
      await tester.pump();
      expect(tester.widget<TextField>(answerField).controller!.text, '-17');
    },
  );

  testWidgets(
    'A correct check hides the keypad and locks the answer field',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MathRiddleApp());
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Addition Riddle'));
      await tester.pumpAndSettle();

      // Reveal the solution to learn the correct answer, then clear the
      // resulting feedback by typing it in via the keypad.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Solution'));
      await tester.pump();
      final solutionText = tester
          .widget<Text>(find.textContaining('Answer: '))
          .data!;
      final correctAnswer = solutionText.substring('Answer: '.length);

      for (final digit in correctAnswer.split('')) {
        await tester.tap(find.widgetWithText(OutlinedButton, digit));
      }
      await tester.pump();

      final answerField = find.byType(TextField).first;
      expect(tester.widget<TextField>(answerField).controller!.text, correctAnswer);
      expect(tester.widget<TextField>(answerField).readOnly, isFalse);

      await tester.tap(find.widgetWithText(FilledButton, 'Check'));
      await tester.pump();

      expect(find.text('Correct!'), findsOneWidget);
      expect(tester.widget<TextField>(answerField).readOnly, isTrue);
      // The digit keypad (1-9, 0, C, backspace) is gone.
      expect(find.widgetWithText(OutlinedButton, '5'), findsNothing);
      expect(find.byIcon(Icons.backspace_outlined), findsNothing);

      // Next riddle brings the keypad back and unlocks the field.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Next riddle'));
      await tester.pump();
      expect(find.widgetWithText(OutlinedButton, '5'), findsOneWidget);
      expect(tester.widget<TextField>(answerField).readOnly, isFalse);
    },
  );

  testWidgets('Hint button only appears for riddles that define a hint', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MathRiddleApp());
    await tester.tap(find.text('Play'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Addition Riddle'));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
  });

  testWidgets(
    'Sequence riddle hint reveals a term at a time, then the formula',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MathRiddleApp());
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sequence Riddle'));
      await tester.pumpAndSettle();

      String sequenceText() =>
          tester.widget<Text>(find.textContaining('?')).data!;
      int termCount() => sequenceText().split(', ').length - 1;

      // The definition text is "f(n) = ..." for the quadratic/cubic
      // riddles, or "x_0 = ..., x_1 = ..., x_n = ..." for the recursive
      // one — funType is random, so accept either.
      bool definitionShown() =>
          find.textContaining('f(n) =').evaluate().isNotEmpty ||
          find.textContaining('x_n =').evaluate().isNotEmpty;

      final initialTermCount = termCount();
      expect(definitionShown(), isFalse);

      for (var extraTerms = 1; extraTerms <= 3; extraTerms++) {
        await tester.tap(find.byIcon(Icons.lightbulb_outline));
        await tester.pump();
        expect(termCount(), initialTermCount + extraTerms);
      }

      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      await tester.tap(find.byIcon(Icons.lightbulb_outline));
      await tester.pump();

      expect(definitionShown(), isTrue);
      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    },
  );

  testWidgets(
    'Tapping the riddle canvas adds a note; the reset button clears it',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MathRiddleApp());
      await tester.tap(find.text('Play'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Addition Riddle'));
      await tester.pumpAndSettle();

      // Only the answer field exists before any note is added.
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt), findsNothing);

      await tester.tapAt(const Offset(60, 60));
      await tester.pumpAndSettle();

      // A second, editable note field appeared alongside the answer field.
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byIcon(Icons.restart_alt), findsOneWidget);

      // Locate the note field via its close icon (a sibling in the same
      // Row), rather than by tree order, since that's ambiguous relative
      // to the answer field.
      final noteRow = find.ancestor(
        of: find.byIcon(Icons.close),
        matching: find.byType(Row),
      );
      final noteField = find.descendant(
        of: noteRow,
        matching: find.byType(TextField),
      );
      final noteBox = find.ancestor(
        of: noteField,
        matching: find.byType(SizedBox),
      );

      await tester.enterText(noteField, '3');
      await tester.pump();
      expect(tester.widget<TextField>(noteField).controller!.text, '3');
      expect(find.byType(TextField), findsNWidgets(2));
      final shortWidth = tester.widget<SizedBox>(noteBox).width!;

      await tester.enterText(noteField, '3, 6, 9, 12, 15, 18');
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(TextField), findsNWidgets(2));
      final longWidth = tester.widget<SizedBox>(noteBox).width!;
      expect(longWidth, greaterThan(shortWidth));

      await tester.tap(find.byIcon(Icons.restart_alt));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.restart_alt), findsNothing);
    },
  );
}
