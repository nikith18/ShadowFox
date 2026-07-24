import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/providers/calculator_provider.dart';
import 'package:my_app/services/calculator_service.dart';
import 'package:my_app/models/calculator_state.dart';
import 'package:my_app/widgets/calc_button.dart';

void main() {
  group('CalculatorService', () {
    final CalculatorService service = CalculatorService();

    test('evaluates display operators and respects precedence', () {
      expect(service.evaluate('12×3+4'), '40');
      expect(service.evaluate('20÷5'), '4');
    });

    test('keeps live previews valid for incomplete input', () {
      expect(service.evaluate('12+'), '12');
      expect(service.evaluate('1.'), '1');
    });

    test('applies percentage based on the active operation', () {
      expect(service.evaluatePercent('200+10'), '220');
      expect(service.evaluatePercent('200-10'), '180');
      expect(service.evaluatePercent('200×10'), '20');
      expect(service.evaluatePercent('50'), '0.5');
    });

    test('evaluates scientific expressions', () {
      expect(service.evaluate('sqrt(81)'), '9');
      expect(service.evaluate('3^2'), '9');
      expect(service.evaluate('5!'), '120');
    });
  });

  group('CalculatorProvider', () {
    CalculatorProvider createCalculator() =>
        CalculatorProvider(calculatorService: CalculatorService());

    test('button input builds and evaluates an expression', () {
      final CalculatorProvider calculator = createCalculator();

      for (final String key in ['1', '2', '+', '3', '=']) {
        calculator.onButtonPressed(key);
      }

      expect(calculator.state.expression, '12+3');
      expect(calculator.state.result, '15');
      expect(calculator.state.justEvaluated, isTrue);
    });

    test('decimal, delete, clear and sign toggle work', () {
      final CalculatorProvider calculator = createCalculator();

      for (final String key in ['5', '.', '2', CalculatorProvider.backspace]) {
        calculator.onButtonPressed(key);
      }
      expect(calculator.state.expression, '5.');

      calculator.onButtonPressed(CalculatorProvider.plusMinus);
      expect(calculator.state.result, '-5');

      calculator.onButtonPressed('AC');
      expect(calculator.state.result, '0');
      expect(calculator.state.expression, isEmpty);
    });
  });

  testWidgets('calculator button delivers its tap callback', (tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            height: 100,
            child: CalcButton(
              label: '7',
              type: ButtonType.number,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();

    expect(pressed, isTrue);
  });
}
