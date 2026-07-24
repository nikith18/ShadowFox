import 'package:math_expressions/math_expressions.dart';

/// Pure service class that safely evaluates mathematical expression strings.
///
/// Using [math_expressions] package instead of dart:math eval so we never
/// invoke `dart:mirrors` or `eval()` – keeping the app tree-shaking friendly
/// and avoiding any security concerns from executing arbitrary code.
class CalculatorService {
  // Reuse parser and context across calls to avoid repeated instantiation.
  // GrammarParser is the recommended non-deprecated parser in math_expressions 2.6+
  final GrammarParser _parser = GrammarParser();
  final ContextModel _context = ContextModel();

  /// Evaluates [expression] and returns the result as a formatted string.
  ///
  /// Handles:
  /// * Division by zero → returns "Cannot divide by zero"
  /// * Empty or blank input → returns "0"
  /// * Any parse / evaluation error → returns "Error"
  /// * Large/overflow numbers → returns "Overflow"
  ///
  /// The expression uses '×' and '÷' as display characters; these are
  /// normalised to '*' and '/' before evaluation.
  String evaluate(String expression) {
    try {
      if (expression.trim().isEmpty) return '0';

      // Normalise display operators to math_expressions compatible operators
      String normalised = expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-');

      // Guard: expression must not end with an operator
      if (RegExp(r'[+\-*/%]$').hasMatch(normalised.trim())) {
        return expression.split('').last; // Keep last digit or partial display
      }

      final Expression exp = _parser.parse(normalised);
      final double result = exp.evaluate(EvaluationType.REAL, _context);

      // Handle special floating point values
      if (result.isNaN) return 'Invalid Expression';
      if (result.isInfinite) return 'Cannot divide by zero';
      if (result.abs() > 1e15) return 'Overflow';

      // Format: remove unnecessary .0 for integers
      if (result == result.truncateToDouble()) {
        return result.toInt().toString();
      }

      // Limit decimal places to 10 to avoid floating-point noise
      String formatted = result.toStringAsFixed(10);
      // Trim trailing zeros after decimal
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      return formatted;
    } catch (e) {
      // IntegerDivisionByZeroException is handled via result.isInfinite above.
      // This catch-all ensures no other exception escapes.
      return 'Error';
    }
  }

  /// Evaluates percentage: interprets expression as "expression / 100".
  /// e.g. "50" → "0.5", "200 + 50%" applies 50% of 200.
  String evaluatePercent(String expression) {
    try {
      if (expression.trim().isEmpty) return '0';

      // If there's an operator in the expression, apply % to last operand
      final RegExp opSplit = RegExp(r'([+\-×÷])');
      final List<String> parts = expression.split(opSplit);

      if (parts.length >= 2) {
        final String lastPart = parts.last;
        final double lastNum = double.parse(lastPart);
        final String baseExpr = expression.substring(
          0,
          expression.length - lastPart.length,
        );
        final double base = double.parse(
          evaluate(baseExpr.substring(0, baseExpr.length - 1)),
        );
        final double percent = base * (lastNum / 100);

        // Re-evaluate with the percentage value substituted
        return evaluate(
          '$baseExpr${percent.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}',
        );
      }

      // Simple case: just divide by 100
      return evaluate('$expression/100');
    } catch (_) {
      return 'Error';
    }
  }
}
