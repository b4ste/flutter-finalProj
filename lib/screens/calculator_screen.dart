import 'package:flutter/material.dart';
import '../logic/expression_evaluator.dart';
import '../state/app_state.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.state,
    required this.reusedExpression,
    required this.onExpressionUsed,
  });
  final AppState state;
  final String? reusedExpression;
  final VoidCallback onExpressionUsed;
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String expression = '';
  String display = '0';
  double? lastValue;
  bool justEvaluated = false;

  @override
  void didUpdateWidget(CalculatorScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reusedExpression != null) {
      expression = widget.reusedExpression!;
      display = 'Tap = to calculate';
      lastValue = null;
      justEvaluated = false;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => widget.onExpressionUsed(),
      );
    }
  }

  void press(String key) {
    if (key == 'DEG' || key == 'RAD') {
      widget.state.setDegrees(!widget.state.degrees);
      return;
    }
    if (key == 'MC') {
      widget.state.setMemory(0);
      return;
    }
    if (key == 'MR') {
      setState(() {
        expression += '(${formatResult(widget.state.memory)})';
        display = '0';
        lastValue = null;
        justEvaluated = false;
      });
      return;
    }
    if (key == 'M+' || key == 'M−') {
      try {
        final value =
            lastValue ??
            ExpressionEvaluator(
              degrees: widget.state.degrees,
            ).evaluate(expression);
        widget.state.setMemory(
          widget.state.memory + (key == 'M+' ? value : -value),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Memory: ${formatResult(widget.state.memory)}'),
          ),
        );
      } on CalculationException catch (error) {
        setState(() => display = error.message);
      }
      return;
    }
    setState(() {
      if (key == 'AC') {
        expression = '';
        display = '0';
        lastValue = null;
        justEvaluated = false;
        return;
      }
      if (key == 'DEL') {
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
        display = '0';
        lastValue = null;
        justEvaluated = false;
        return;
      }
      if (key == '=') {
        try {
          final result = ExpressionEvaluator(
            degrees: widget.state.degrees,
          ).evaluate(expression);
          display = formatResult(result);
          lastValue = result;
          justEvaluated = true;
          widget.state.addCalculation(expression, result);
        } on CalculationException catch (error) {
          display = error.message;
          lastValue = null;
        }
        return;
      }
      if (justEvaluated &&
          (RegExp(r'^[0-9.]$').hasMatch(key) ||
              key == 'π' ||
              key == 'e' ||
              key.endsWith('('))) {
        expression = '';
      }
      justEvaluated = false;
      display = '0';
      lastValue = null;
      expression += switch (key) {
        'x²' => '^2',
        'x³' => '^3',
        'xʸ' => '^',
        'n√x' => 'root(',
        '1/x' => 'inv(',
        '|x|' => 'abs(',
        '√' => 'sqrt(',
        _ => key,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    const scientific = [
      'sin(',
      'cos(',
      'tan(',
      'asin(',
      'acos(',
      'atan(',
      'x²',
      'x³',
      'xʸ',
      '√',
      'n√x',
      'log(',
      'ln(',
      '!',
      '|x|',
      '1/x',
      'π',
      'e',
      ',',
    ];
    const keys = [
      ['AC', 'DEL', '(', ')', '÷'],
      ['7', '8', '9', '%', '×'],
      ['4', '5', '6', 'xʸ', '−'],
      ['1', '2', '3', '√', '+'],
      ['π', '0', '.', 'e', '='],
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      'SCIENTIFIC • ${widget.state.degrees ? 'DEG' : 'RAD'}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.state.memory == 0
                          ? ''
                          : 'M ${formatResult(widget.state.memory)}',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    expression.isEmpty ? '0' : expression,
                    style: const TextStyle(fontSize: 27),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  display,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inverse trig results: ${widget.state.degrees ? 'degrees' : 'radians'}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final key in ['DEG', 'RAD', 'MC', 'MR', 'M+', 'M−'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: OutlinedButton(
                    onPressed: () => press(key),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 1,
                      ),
                      backgroundColor:
                          (key == 'DEG' && widget.state.degrees ||
                              key == 'RAD' && !widget.state.degrees)
                          ? accent.withValues(alpha: 0.25)
                          : null,
                    ),
                    child: Text(key, style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'FUNCTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: accent,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            for (final key in scientific)
              ActionChip(
                label: Text(key, style: const TextStyle(fontSize: 13)),
                onPressed: () => press(key),
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'n√x: enter degree, comma, value, then )',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 10),
        for (final row in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: () => press(key),
                          style: FilledButton.styleFrom(
                            backgroundColor: key == '='
                                ? accent
                                : ([
                                        '+',
                                        '−',
                                        '×',
                                        '÷',
                                        'AC',
                                        'DEL',
                                      ].contains(key)
                                      ? const Color(0xFF25415A)
                                      : const Color(0xFF192B40)),
                            foregroundColor: key == '='
                                ? Colors.black
                                : Colors.white,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            key,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
