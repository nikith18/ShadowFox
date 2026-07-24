import 'package:flutter/foundation.dart';
import '../models/calculator_state.dart';
import '../services/calculator_service.dart';

/// The heart of the Smart Modern Calculator.
///
/// [CalculatorProvider] implements a **state machine** for user input so that
/// invalid sequences (consecutive operators, multiple decimals, leading zeros)
/// are silently rejected rather than causing crashes or confusing output.
///
/// State flags:
///   • [state.isLastInputOperator]  – last token was an operator
///   • [state.isLastInputDigit]     – last token was a digit/decimal
///   • [state.hasDot]               – current number segment has a decimal
///   • [state.justEvaluated]        – user just pressed "="
///
/// This mirrors an Android ViewModel in the clean-architecture sense:
/// the provider holds state + business logic; widgets only observe and dispatch.
class CalculatorProvider extends ChangeNotifier {
  final CalculatorService _service;

  CalculatorProvider({required CalculatorService calculatorService})
    : _service = calculatorService;

  // The single source of truth for all calculator UI state.
  CalculatorState _state = const CalculatorState();

  /// Exposes the current immutable state snapshot.
  CalculatorState get state => _state;

  // ──────────────────────────────────────────────
  //  PUBLIC API – called by the UI layer
  // ──────────────────────────────────────────────

  /// Main entry point: dispatches button presses to the correct handler.
  void onButtonPressed(String value) {
    if (value == 'AC') {
      _handleClear();
    } else if (value == '⌫') {
      _handleDelete();
    } else if (value == '=') {
      _handleEquals();
    } else if (value == '±') {
      _handleToggleSign();
    } else if (value == '%') {
      _handlePercent();
    } else if (_isOperator(value)) {
      _handleOperator(value);
    } else if (value == '.') {
      _handleDecimal();
    } else {
      _handleDigit(value);
    }
  }

  /// Long-press on delete clears everything (convenience shortcut).
  void onDeleteLongPress() => _handleClear();

  // ──────────────────────────────────────────────
  //  INPUT HANDLERS
  // ──────────────────────────────────────────────

  void _handleDigit(String digit) {
    String newExpr;

    if (_state.justEvaluated) {
      // Starting fresh after an evaluation: replace expression with new digit
      newExpr = digit;
    } else {
      // Prevent consecutive leading zeros like "00123"
      if (digit == '0' && _state.expression == '0') return;
      newExpr = _state.expression + digit;
    }

    _state = _state.copyWith(
      expression: newExpr,
      isLastInputOperator: false,
      isLastInputDigit: true,
      justEvaluated: false,
      // hasDot stays same; it's only reset in _handleOperator / _handleClear
    );

    _computeLiveResult();
  }

  void _handleOperator(String op) {
    if (_state.expression.isEmpty) {
      // Don't allow an expression to start with an operator (except minus for
      // unary negation – future enhancement; for now just ignore).
      return;
    }

    String newExpr;

    if (_state.justEvaluated) {
      // Continue with the result of the previous evaluation
      newExpr = _state.result + op;
    } else if (_state.isLastInputOperator) {
      // Replace the last operator instead of stacking them (e.g. "5+" then "×" → "5×")
      newExpr =
          _state.expression.substring(0, _state.expression.length - 1) + op;
    } else {
      newExpr = _state.expression + op;
    }

    _state = _state.copyWith(
      expression: newExpr,
      isLastInputOperator: true,
      isLastInputDigit: false,
      hasDot: false, // New operand starts; reset decimal flag
      justEvaluated: false,
    );

    // Don't update live result here – the expression ending in an operator
    // is not a valid evaluable expression.
  }

  void _handleDecimal() {
    if (_state.hasDot) return; // Already have a decimal in this number segment

    String newExpr;

    if (_state.expression.isEmpty ||
        _state.isLastInputOperator ||
        _state.justEvaluated) {
      // Auto-prefix "0." if decimal is first character or comes after operator
      final String prefix = _state.justEvaluated ? '' : _state.expression;
      newExpr = '${prefix}0.';
    } else {
      newExpr = '${_state.expression}.';
    }

    _state = _state.copyWith(
      expression: newExpr,
      hasDot: true,
      isLastInputOperator: false,
      isLastInputDigit: false,
      justEvaluated: false,
    );
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
      // Keep expression visible so user can see what they evaluated
    );

    notifyListeners();
  }

  void _handleClear() {
    _state = const CalculatorState();
    notifyListeners();
  }

  void _handleDelete() {
    final String expr = _state.expression;
    if (expr.isEmpty) return;

    final String newExpr = expr.substring(0, expr.length - 1);

    // Re-evaluate flags from the new trimmed expression
    final bool lastIsOp =
        newExpr.isNotEmpty && _isOperator(newExpr[newExpr.length - 1]);
    final bool lastIsDigitChar =
        newExpr.isNotEmpty &&
        RegExp(r'[0-9]').hasMatch(newExpr[newExpr.length - 1]);

    // Re-detect whether a dot exists in the current number segment.
    // "Current segment" is the substring after the last operator.
    final bool dotExists = _currentSegmentHasDot(newExpr);

    _state = _state.copyWith(
      expression: newExpr,
      result: newExpr.isEmpty ? '0' : _state.result,
      isLastInputOperator: lastIsOp,
      isLastInputDigit: lastIsDigitChar,
      hasDot: dotExists,
      justEvaluated: false,
    );

    if (newExpr.isNotEmpty && !lastIsOp) {
      _computeLiveResult();
    } else {
      notifyListeners();
    }
  }

  void _handleToggleSign() {
    if (_state.expression.isEmpty) return;

    // Find the start of the last number segment
    int lastOpIndex = -1;
    for (int i = _state.expression.length - 1; i >= 0; i--) {
      if (_isOperator(_state.expression[i]) && i != 0) {
        lastOpIndex = i;
        break;
      }
    }

    final String beforeSegment = lastOpIndex >= 0
        ? _state.expression.substring(0, lastOpIndex + 1)
        : '';
    final String segment = lastOpIndex >= 0
        ? _state.expression.substring(lastOpIndex + 1)
        : _state.expression;

    if (segment.isEmpty) return;

    String newSegment;
    if (segment.startsWith('-')) {
      newSegment = segment.substring(1); // Remove leading minus
    } else {
      newSegment = '-$segment'; // Add leading minus
    }

    _state = _state.copyWith(
      expression: beforeSegment + newSegment,
      justEvaluated: false,
    );

    _computeLiveResult();
  }

  void _handlePercent() {
    if (_state.expression.isEmpty || _state.isLastInputOperator) return;

    final String result = _service.evaluatePercent(_state.expression);

    _state = _state.copyWith(
      result: result,
      isLastInputOperator: false,
      isLastInputDigit: false,
      hasDot: result.contains('.'),
      justEvaluated: true,
    );

    notifyListeners();
  }

  // ──────────────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────────────

  /// Computes a live preview result and notifies listeners.
  /// Called after every digit/decimal input so the result area updates
  /// in real time without requiring the user to press "=".
  void _computeLiveResult() {
    final String liveResult = _service.evaluate(_state.expression);
    _state = _state.copyWith(result: liveResult);
    notifyListeners();
  }

  bool _isOperator(String ch) => '+-×÷'.contains(ch);

  /// Finds the last operator position in [expr] and checks whether the
  /// current number segment (after the last operator) contains a decimal point.
  bool _currentSegmentHasDot(String expr) {
    if (expr.isEmpty) return false;
    // Walk backwards to find the start of the current segment
    for (int i = expr.length - 1; i >= 0; i--) {
      if (_isOperator(expr[i])) {
        return expr.substring(i + 1).contains('.');
      }
    }
    return expr.contains('.');
  }

  // ──────────────────────────────────────────────
  //  FUTURE: Scientific Mode
  // ──────────────────────────────────────────────
  // TODO(future): Add a `isScientificMode` flag and expose:
  //   sin(), cos(), tan(), log(), ln(), sqrt(), pow(), factorial()
  // These operations should be routed here as named button values
  // and evaluated via CalculatorService.evaluate() after inserting
  // the appropriate function prefix (e.g. "sin(" + segment + ")").

  // TODO(future): Voice input hook
  // The `onVoiceInput(String rawText)` method should parse natural language
  // like "five plus ten" and convert to an expression string before calling
  // the existing state machine handlers.
}
