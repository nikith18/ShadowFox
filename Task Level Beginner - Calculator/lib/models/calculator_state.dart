/// Enum representing the type of each calculator button.
/// This drives UI styling (color, size) and logic handling.
enum ButtonType {
  /// Digits 0–9
  number,

  /// Arithmetic operators: +, −, ×, ÷
  operator,

  /// The equals (=) button
  equals,

  /// Utility buttons: AC, ±, %
  utility,

  /// Delete / backspace
  delete,

  /// Decimal point
  decimal,
}

/// Immutable snapshot of the calculator's current UI state.
/// The [CalculatorProvider] exposes this to the widget tree.
class CalculatorState {
  /// The expression currently being built (e.g. "12 + 5 × 3")
  final String expression;

  /// The live result shown below the expression.
  /// Shows "0" by default, an error string on failure.
  final String result;

  /// Whether the last character entered was an operator.
  /// Used by the input state machine to prevent consecutive operators.
  final bool isLastInputOperator;

  /// Whether the last character entered was a digit or a closing paren.
  final bool isLastInputDigit;

  /// Whether the current number segment already contains a decimal point.
  final bool hasDot;

  /// When true, the expression has just been evaluated (user pressed "=").
  /// Pressing a digit after evaluation starts fresh; an operator continues.
  final bool justEvaluated;

  const CalculatorState({
    this.expression = '',
    this.result = '0',
    this.isLastInputOperator = false,
    this.isLastInputDigit = false,
    this.hasDot = false,
    this.justEvaluated = false,
  });

  /// Creates a copy of the state with the given fields overridden.
  /// Follows the immutable-state pattern common in Flutter state management.
  CalculatorState copyWith({
    String? expression,
    String? result,
    bool? isLastInputOperator,
    bool? isLastInputDigit,
    bool? hasDot,
    bool? justEvaluated,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      isLastInputOperator: isLastInputOperator ?? this.isLastInputOperator,
      isLastInputDigit: isLastInputDigit ?? this.isLastInputDigit,
      hasDot: hasDot ?? this.hasDot,
      justEvaluated: justEvaluated ?? this.justEvaluated,
    );
  }
}
