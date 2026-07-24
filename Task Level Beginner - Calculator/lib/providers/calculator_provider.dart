import 'package:flutter/foundation.dart';
import '../models/calculator_state.dart';
import '../services/calculator_service.dart';

class CalculatorProvider extends ChangeNotifier {
  static const String backspace = '⌫';
  static const String plusMinus = '±';
  static const String multiply = '×';
  static const String divide = '÷';

  static const Set<String> scientificFunctions = {
    'sin',
    'cos',
    'tan',
    'log',
    'ln',
    'sqrt',
    'pow',
    'factorial',
  };

  final CalculatorService _service;

  CalculatorProvider({required CalculatorService calculatorService})
    : _service = calculatorService;

  CalculatorState _state = const CalculatorState();

  CalculatorState get state => _state;

  void onButtonPressed(String value) {
    switch (value) {
      case 'AC':
        _handleClear();
      case backspace:
        _handleDelete();
      case '=':
        _handleEquals();
      case plusMinus:
        _handleToggleSign();
      case '%':
        _handlePercent();
      case 'sin':
      case 'cos':
      case 'tan':
      case 'log':
      case 'ln':
      case 'sqrt':
      case 'pow':
      case 'factorial':
        _handleScientific(value);
      case '+':
      case '-':
      case multiply:
      case divide:
        _handleOperator(value);
      case '.':
        _handleDecimal();
      default:
        if (RegExp(r'^\d$').hasMatch(value)) _handleDigit(value);
    }
  }

  void onDeleteLongPress() => _handleClear();

  void _handleDigit(String digit) {
    final bool startingNewExpression = _state.justEvaluated;
    final String currentSegment = _currentSegment(_state.expression);

    if (!startingNewExpression && digit == '0' && currentSegment == '0') {
      return;
    }

    final String newExpression = startingNewExpression
        ? digit
        : _state.expression + digit;

    _state = _state.copyWith(
      expression: newExpression,
      result: newExpression,
      isLastInputOperator: false,
      isLastInputDigit: true,
      hasDot: _currentSegmentHasDot(newExpression),
      justEvaluated: false,
    );

    _computeLiveResult();
  }

  void _handleOperator(String operator) {
    if (_state.expression.isEmpty) {
      // A leading minus is useful for negative numbers; the other operators
      // have no meaningful left-hand side yet.
      if (operator != '-') return;
      _state = _state.copyWith(
        expression: '-',
        result: '0',
        isLastInputOperator: true,
        isLastInputDigit: false,
        hasDot: false,
        justEvaluated: false,
      );
      notifyListeners();
      return;
    }

    if (_state.expression == '-' && _state.isLastInputOperator) return;
    if (_state.justEvaluated && !_isNumeric(_state.result)) return;

    String newExpression;
    if (_state.justEvaluated && _isNumeric(_state.result)) {
      newExpression = '${_state.result}$operator';
    } else if (_state.isLastInputOperator) {
      newExpression =
          '${_state.expression.substring(0, _state.expression.length - 1)}$operator';
    } else {
      newExpression = _state.expression + operator;
    }

    _state = _state.copyWith(
      expression: newExpression,
      isLastInputOperator: true,
      isLastInputDigit: false,
      hasDot: false,
      justEvaluated: false,
    );
    _computeLiveResult();
  }

  void _handleDecimal() {
    if (_state.hasDot && !_state.justEvaluated) return;

    final String newExpression;
    if (_state.expression.isEmpty ||
        _state.isLastInputOperator ||
        _state.justEvaluated) {
      newExpression = '${_state.justEvaluated ? '' : _state.expression}0.';
    } else {
      newExpression = '${_state.expression}.';
    }

    _state = _state.copyWith(
      expression: newExpression,
      result: newExpression,
      hasDot: true,
      isLastInputOperator: false,
      isLastInputDigit: false,
      justEvaluated: false,
    );
    _computeLiveResult();
  }

  void _handleEquals() {
    if (_state.expression.isEmpty || _state.isLastInputOperator) return;

    final String result = _service.evaluate(_state.expression);
    _state = _state.copyWith(
      result: result,
      isLastInputOperator: false,
      isLastInputDigit: false,
      hasDot: false,
      justEvaluated: true,
    );
    notifyListeners();
  }

  void _handleClear() {
    final bool scientificMode = _state.isScientificMode;
    _state = CalculatorState(isScientificMode: scientificMode);
    notifyListeners();
  }

  void _handleDelete() {
    if (_state.expression.isEmpty) return;

    final String newExpression = _state.expression.substring(
      0,
      _state.expression.length - 1,
    );
    final bool lastIsOperator =
        newExpression.isNotEmpty &&
        _isOperator(newExpression[newExpression.length - 1]);

    _state = _state.copyWith(
      expression: newExpression,
      result: newExpression.isEmpty ? '0' : _state.result,
      isLastInputOperator: lastIsOperator,
      isLastInputDigit: !lastIsOperator && newExpression.isNotEmpty,
      hasDot: _currentSegmentHasDot(newExpression),
      justEvaluated: false,
    );

    if (newExpression.isEmpty || lastIsOperator) {
      notifyListeners();
    } else {
      _computeLiveResult();
    }
  }

  void _handleToggleSign() {
    if (_state.justEvaluated && _isNumeric(_state.result)) {
      final String signedResult = _state.result.startsWith('-')
          ? _state.result.substring(1)
          : '-${_state.result}';
      _state = _state.copyWith(
        expression: signedResult,
        result: signedResult,
        justEvaluated: false,
        isLastInputDigit: true,
      );
      _computeLiveResult();
      return;
    }

    if (_state.expression.isEmpty || _state.expression == '-') return;

    final int operatorIndex = _findLastBinaryOperator(_state.expression);
    final String beforeSegment = operatorIndex < 0
        ? ''
        : _state.expression.substring(0, operatorIndex + 1);
    final String segment = operatorIndex < 0
        ? _state.expression
        : _state.expression.substring(operatorIndex + 1);

    if (segment.isEmpty) return;
    final String newSegment = segment.startsWith('-')
        ? segment.substring(1)
        : '-$segment';

    _state = _state.copyWith(
      expression: beforeSegment + newSegment,
      justEvaluated: false,
      isLastInputOperator: false,
      isLastInputDigit: true,
    );
    _computeLiveResult();
  }

  void _handlePercent() {
    if (_state.expression.isEmpty || _state.isLastInputOperator) return;

    final String result = _service.evaluatePercent(_state.expression);
    _state = _state.copyWith(
      expression: result,
      result: result,
      isLastInputOperator: false,
      isLastInputDigit: true,
      hasDot: result.contains('.'),
      justEvaluated: true,
    );
    notifyListeners();
  }

  void _computeLiveResult() {
    final String liveResult = _service.evaluate(_state.expression);
    _state = _state.copyWith(result: liveResult);
    notifyListeners();
  }

  void toggleScientificMode() {
    _state = _state.copyWith(isScientificMode: !_state.isScientificMode);
    notifyListeners();
  }

  void _handleScientific(String function) {
    String expression = _state.expression;
    if (_state.justEvaluated && _isNumeric(_state.result)) {
      expression = _state.result;
    }
    if (expression.isEmpty || expression == '-') return;

    final int operatorIndex = _findLastBinaryOperator(expression);
    final String beforeSegment = operatorIndex < 0
        ? ''
        : expression.substring(0, operatorIndex + 1);
    final String segment = operatorIndex < 0
        ? expression
        : expression.substring(operatorIndex + 1);

    if (segment.isEmpty || segment == '-') return;

    final String transformedSegment = switch (function) {
      'factorial' => '$segment!',
      'pow' => '$segment^2',
      'sqrt' => 'sqrt($segment)',
      _ => '$function($segment)',
    };

    _state = _state.copyWith(
      expression: beforeSegment + transformedSegment,
      justEvaluated: false,
      isLastInputOperator: false,
      isLastInputDigit: true,
      hasDot: false,
    );
    _computeLiveResult();
  }

  /// Converts common spoken calculator phrases into button presses.
  void onVoiceInput(String rawText) {
    final Map<String, String> replacements = {
      'multiplied by': multiply,
      'divided by': divide,
      'plus': '+',
      'add': '+',
      'minus': '-',
      'subtract': '-',
      'times': multiply,
      'over': divide,
      'equals': '=',
      'zero': '0',
      'one': '1',
      'two': '2',
      'three': '3',
      'four': '4',
      'five': '5',
      'six': '6',
      'seven': '7',
      'eight': '8',
      'nine': '9',
      'ten': '10',
    };

    String parsed = rawText.toLowerCase();
    for (final MapEntry<String, String> replacement in replacements.entries) {
      parsed = parsed.replaceAll(replacement.key, replacement.value);
    }

    _handleClear();
    for (final String character
        in parsed.replaceAll(RegExp(r'\s+'), '').split('')) {
      onButtonPressed(character);
    }
  }

  String _currentSegment(String expression) {
    if (expression.isEmpty) return '';
    final int operatorIndex = _findLastBinaryOperator(expression);
    return operatorIndex < 0
        ? expression
        : expression.substring(operatorIndex + 1);
  }

  bool _currentSegmentHasDot(String expression) =>
      _currentSegment(expression).contains('.');

  int _findLastBinaryOperator(String expression) {
    for (int index = expression.length - 1; index >= 0; index--) {
      final String character = expression[index];
      if (!_isOperator(character)) continue;
      if (character == '-' &&
          (index == 0 || _isOperator(expression[index - 1]))) {
        continue;
      }
      return index;
    }
    return -1;
  }

  bool _isOperator(String character) => '+-×÷'.contains(character);

  bool _isNumeric(String value) => double.tryParse(value) != null;
}
