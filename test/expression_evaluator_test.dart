import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';
import 'package:finalproject/logic/expression_evaluator.dart';

void main() {
  test('operator precedence, parentheses, powers and roots', () {
    final calc = ExpressionEvaluator();
    expect(calc.evaluate('2+3×4'), 14);
    expect(calc.evaluate('(2+3)×4'), 20);
    expect(calc.evaluate('-2^2'), -4);
    expect(calc.evaluate('2^3^2'), 512);
    expect(calc.evaluate('root(3,-8)'), closeTo(-2, 1e-10));
    expect(calc.evaluate('5!+50%'), 120.5);
  });

  test('trig mode applies to both directions', () {
    expect(
      ExpressionEvaluator(degrees: true).evaluate('sin(30)'),
      closeTo(0.5, 1e-10),
    );
    expect(
      ExpressionEvaluator(degrees: true).evaluate('asin(0.5)'),
      closeTo(30, 1e-10),
    );
    expect(
      ExpressionEvaluator(degrees: false).evaluate('sin(pi/2)'),
      closeTo(1, 1e-10),
    );
    expect(
      ExpressionEvaluator(degrees: false).evaluate('asin(1)'),
      closeTo(math.pi / 2, 1e-10),
    );
  });

  test('invalid mathematical domains produce errors', () {
    final calc = ExpressionEvaluator();
    for (final expression in [
      '1/0',
      'sqrt(-1)',
      'ln(0)',
      '(-1)!',
      'tan(90)',
      'acos(2)',
      'root(2,-4)',
      '2+',
    ]) {
      expect(
        () => calc.evaluate(expression),
        throwsA(isA<CalculationException>()),
        reason: expression,
      );
    }
  });
}
