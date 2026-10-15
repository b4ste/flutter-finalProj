import 'dart:math' as math;

class CalculationException implements Exception {
  CalculationException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ExpressionEvaluator {
  ExpressionEvaluator({this.degrees = true});
  final bool degrees;
  late String _source;
  int _index = 0;

  double evaluate(String source) {
    _source = source
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi');
    _index = 0;
    if (_source.trim().isEmpty) {
      throw CalculationException('Enter an expression');
    }
    final result = _expression();
    _space();
    if (_index != _source.length) {
      throw CalculationException(
        'Unexpected input near "${_source.substring(_index)}"',
      );
    }
    return _finite(result);
  }

  double _expression() {
    var left = _term();
    while (true) {
      if (_take('+')) {
        left += _term();
      } else if (_take('-')) {
        left -= _term();
      } else {
        return _finite(left);
      }
    }
  }

  double _term() {
    var left = _unary();
    while (true) {
      if (_take('*')) {
        left *= _unary();
      } else if (_take('/')) {
        final right = _unary();
        if (right == 0) throw CalculationException('Cannot divide by zero');
        left /= right;
      } else {
        return _finite(left);
      }
    }
  }

  double _unary() {
    if (_take('+')) return _unary();
    if (_take('-')) return -_unary();
    return _power();
  }

  double _power() {
    var left = _postfix();
    if (_take('^')) left = math.pow(left, _unary()).toDouble();
    return _finite(left);
  }

  double _postfix() {
    var value = _primary();
    while (true) {
      if (_take('%')) {
        value /= 100;
      } else if (_take('!')) {
        if (value < 0 || value > 170 || value != value.roundToDouble()) {
          throw CalculationException(
            'Factorial requires an integer from 0 to 170',
          );
        }
        var answer = 1.0;
        for (var i = 2; i <= value.toInt(); i++) {
          answer *= i;
        }
        value = answer;
      } else {
        return _finite(value);
      }
    }
  }

  double _primary() {
    if (_take('(')) {
      final value = _expression();
      if (!_take(')')) {
        throw CalculationException('Missing closing parenthesis');
      }
      return value;
    }
    _space();
    if (_index >= _source.length) {
      throw CalculationException('Incomplete expression');
    }
    final start = _index;
    if (_letter(_source[_index])) {
      while (_index < _source.length && _letter(_source[_index])) {
        _index++;
      }
      final name = _source.substring(start, _index).toLowerCase();
      if (name == 'pi') return math.pi;
      if (name == 'e') return math.e;
      if (!_take('(')) throw CalculationException('Use $name(...)');
      final first = _expression();
      double? second;
      if (_take(',')) second = _expression();
      if (!_take(')')) {
        throw CalculationException('Missing closing parenthesis');
      }
      return _function(name, first, second);
    }
    while (_index < _source.length &&
        (RegExp(r'[0-9.]').hasMatch(_source[_index]))) {
      _index++;
    }
    if (start == _index) {
      throw CalculationException('Unexpected character "${_source[_index]}"');
    }
    final value = double.tryParse(_source.substring(start, _index));
    if (value == null) throw CalculationException('Invalid number');
    return value;
  }

  double _function(String name, double x, double? y) {
    if (name == 'root') {
      if (y == null || x == 0) {
        throw CalculationException('Use root(degree, value)');
      }
      if (y < 0 && x != x.roundToDouble()) {
        throw CalculationException('Negative roots need an integer degree');
      }
      if (y < 0 && x.toInt().isEven) {
        throw CalculationException('Even root of a negative number');
      }
      return _finite((y < 0 ? -1 : 1) * math.pow(y.abs(), 1 / x).toDouble());
    }
    if (y != null) throw CalculationException('$name accepts one value');
    final radians = degrees ? x * math.pi / 180 : x;
    switch (name) {
      case 'sin':
        return _finite(math.sin(radians));
      case 'cos':
        return _finite(math.cos(radians));
      case 'tan':
        if (math.cos(radians).abs() < 1e-12) {
          throw CalculationException('Tangent is undefined at this angle');
        }
        return _finite(math.tan(radians));
      case 'asin':
      case 'acos':
        if (x < -1 || x > 1) {
          throw CalculationException('$name requires a value from -1 to 1');
        }
        final result = name == 'asin' ? math.asin(x) : math.acos(x);
        return degrees ? result * 180 / math.pi : result;
      case 'atan':
        return degrees ? math.atan(x) * 180 / math.pi : math.atan(x);
      case 'sqrt':
        if (x < 0) {
          throw CalculationException(
            'Square root requires a nonnegative value',
          );
        }
        return math.sqrt(x);
      case 'log':
      case 'ln':
        if (x <= 0) {
          throw CalculationException('Logarithm requires a positive value');
        }
        return name == 'log' ? math.log(x) / math.ln10 : math.log(x);
      case 'abs':
        return x.abs();
      case 'inv':
        if (x == 0) throw CalculationException('Cannot divide by zero');
        return 1 / x;
      default:
        throw CalculationException('Unknown function: $name');
    }
  }

  bool _letter(String c) => RegExp(r'[a-zA-Z]').hasMatch(c);
  void _space() {
    while (_index < _source.length && _source[_index].trim().isEmpty) {
      _index++;
    }
  }

  bool _take(String c) {
    _space();
    if (_source.startsWith(c, _index)) {
      _index += c.length;
      return true;
    }
    return false;
  }

  double _finite(double value) {
    if (!value.isFinite) {
      throw CalculationException('Result is outside the supported range');
    }
    return value;
  }
}

String formatResult(double value) {
  if (value.abs() < 1e-12) return '0';
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }
  return double.parse(value.toStringAsPrecision(12)).toString();
}
