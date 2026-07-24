enum ButtonType { number, operator, equals, utility, delete, decimal }

class CalculatorState {
  final String expression;

  final String result;

  final bool isLastInputOperator;

  final bool isLastInputDigit;

  final bool hasDot;

  final bool justEvaluated;

  final bool isScientificMode;

  const CalculatorState({
    this.expression = '',
    this.result = '0',
    this.isLastInputOperator = false,
    this.isLastInputDigit = false,
    this.hasDot = false,
    this.justEvaluated = false,
    this.isScientificMode = false,
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    bool? isLastInputOperator,
    bool? isLastInputDigit,
    bool? hasDot,
    bool? justEvaluated,
    bool? isScientificMode,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      isLastInputOperator: isLastInputOperator ?? this.isLastInputOperator,
      isLastInputDigit: isLastInputDigit ?? this.isLastInputDigit,
      hasDot: hasDot ?? this.hasDot,
      justEvaluated: justEvaluated ?? this.justEvaluated,
      isScientificMode: isScientificMode ?? this.isScientificMode,
    );
  }
}
