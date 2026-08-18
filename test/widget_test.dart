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
}
