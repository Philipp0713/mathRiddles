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
}
