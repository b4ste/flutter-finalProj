import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finalproject/main.dart';

void main() {
  testWidgets('transaction amount rejects letters and extra decimal points', (
    tester,
  ) async {
    await tester.pumpWidget(const CalcBudgetApp());
    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    final amount = find.byType(TextFormField).first;
    await tester.enterText(amount, 'abc12.3x');
    expect(tester.widget<TextFormField>(amount).controller!.text, '12.3');
    await tester.enterText(amount, '12.3.4');
    expect(tester.widget<TextFormField>(amount).controller!.text, '12.3');
  });

  testWidgets('fits a narrow phone layout', (tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(const CalcBudgetApp());
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Activity').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('launches calculator, evaluates, and opens budget section', (
    tester,
  ) async {
    await tester.pumpWidget(const CalcBudgetApp());
    expect(find.text('Scientific Calculator'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('2'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('2').last);
    await tester.tap(find.text('+').last);
    await tester.tap(find.text('3').last);
    await tester.tap(find.text('=').last);
    await tester.pump();
    expect(find.text('5'), findsWidgets);
    await tester.tap(find.byIcon(Icons.history).last);
    await tester.pumpAndSettle();
    expect(find.text('2+3'), findsOneWidget);
    await tester.tap(find.text('Dashboard').last);
    await tester.pumpAndSettle();
    expect(find.text('Remaining balance'), findsOneWidget);
    await tester.tap(find.text('Plans').last);
    await tester.pumpAndSettle();
    expect(find.text('Spending limits'), findsOneWidget);
  });
}
