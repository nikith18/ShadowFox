import 'package:math_expressions/math_expressions.dart';

/// Turns the calculator's display expression into a safe, formatted result.
///
/// The UI uses the readable `×` and `÷` symbols, while the parser receives
/// the ASCII operators it understands. Keeping that conversion in one place
/// prevents input and evaluation from drifting apart.
class CalculatorService {
  final GrammarParser _parser = GrammarParser();
  final ContextModel _context = ContextModel();

  String evaluate(String expression) {
    final String normalised = _normalise(expression).trim();
    if (normalised.isEmpty) return '0';

    // Live previews are allowed to end with an operator. Evaluate the part
    // that is complete instead of returning a raw operator as the result.
    String completeExpression = _removeTrailingOperators(normalised);
    if (completeExpression.isEmpty || completeExpression == '-') return '0';
    if (completeExpression.endsWith('.')) {
      completeExpression = '${completeExpression}0';
    }

    try {
      final Expression parsed = _parser.parse(completeExpression);
      final double value = parsed.evaluate(EvaluationType.REAL, _context);

      if (value.isNaN) return 'Invalid expression';
      if (value.isInfinite) return 'Cannot divide by zero';
      if (value.abs() > 1e15) return 'Overflow';

      return _format(value);
    } catch (_) {
      return 'Error';
    }
  }

  /// Applies calculator-style percentage behaviour to the current expression.
  ///
  /// For `200 + 10%`, ten percent is calculated from 200. For multiplication
  /// and division, `10%` behaves as `0.1`, matching a physical calculator.
  String evaluatePercent(String expression) {
    final String trimmed = expression.trim();
    if (trimmed.isEmpty) return '0';

    final int operatorIndex = _findLastBinaryOperator(trimmed);
    if (operatorIndex < 0) {
      return evaluate('$trimmed/100');
    }

    final String leftExpression = trimmed.substring(0, operatorIndex);
    final String operator = trimmed[operatorIndex];
    final String rightExpression = trimmed.substring(operatorIndex + 1);
    final double? right = double.tryParse(_normalise(rightExpression));
    if (right == null) return 'Error';

    final double? left = double.tryParse(evaluate(leftExpression));
    if (left == null) return 'Error';

    final double percentage = operator == '+' || operator == '-'
        ? left * right / 100
        : right / 100;

    final String replacement = _format(percentage);
    return evaluate('$leftExpression$operator$replacement');
  }

  String _normalise(String expression) {
    return expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('√', 'sqrt');
  }

  String _removeTrailingOperators(String expression) {
    String result = expression;
    while (result.isNotEmpty && _isBinaryOperator(result[result.length - 1])) {
      result = result.substring(0, result.length - 1).trimRight();
    }
    return result;
  }

  int _findLastBinaryOperator(String expression) {
    int depth = 0;

    for (int index = expression.length - 1; index >= 0; index--) {
      final String character = expression[index];
      if (character == ')') {
        depth++;
        continue;
      }
      if (character == '(') {
        depth--;
        continue;
      }
      if (depth != 0 || !_isBinaryOperator(character)) continue;

      // A minus directly after another operator is a unary sign, not the
      // operator separating the two values.
      if (character == '-' &&
          (index == 0 || _isBinaryOperator(expression[index - 1]))) {
        continue;
      }
      return index;
    }

    return -1;
  }

  bool _isBinaryOperator(String character) => '+-*/×÷'.contains(character);

  String _format(double value) {
    if (value == 0) return '0';
    if (value == value.truncateToDouble()) return value.toInt().toString();

    String formatted = value.toStringAsFixed(10);
    formatted = formatted.replaceFirst(RegExp(r'0+$'), '');
    formatted = formatted.replaceFirst(RegExp(r'\.$'), '');
    return formatted;
  }
}
