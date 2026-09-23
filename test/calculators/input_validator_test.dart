import 'package:ecocapital/calculators/cash_flow_calculator.dart';
import 'package:ecocapital/calculators/input_validator.dart';
import 'package:ecocapital/models/project_input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const valid = ProjectInput(
    initialInvestment: 1000,
    annualIncome: 500,
    annualCost: 200,
    years: 3,
    discountRate: 0.1,
  );

  group('Validación de valores inválidos', () {
    test('acepta un proyecto válido', () {
      expect(InputValidator.validate(valid), isEmpty);
    });

    test('rechaza inversión cero o negativa', () {
      final input = valid.copyWith(initialInvestment: 0);
      expect(InputValidator.validate(input), isNotEmpty);
    });

    test('rechaza ingresos o costos negativos', () {
      expect(InputValidator.isValid(valid.copyWith(annualIncome: -1)), false);
      expect(InputValidator.isValid(valid.copyWith(annualCost: -1)), false);
    });

    test('rechaza vida del proyecto fuera de rango', () {
      expect(InputValidator.isValid(valid.copyWith(years: 0)), false);
      expect(InputValidator.isValid(valid.copyWith(years: 31)), false);
    });

    test('rechaza tasas fuera de rango', () {
      expect(InputValidator.isValid(valid.copyWith(discountRate: -0.1)), false);
      expect(InputValidator.isValid(valid.copyWith(discountRate: 1.5)), false);
    });

    test('rechaza valores no finitos', () {
      final input = valid.copyWith(annualIncome: double.nan);
      expect(InputValidator.isValid(input), false);
    });

    test('el calculador lanza error con datos inválidos', () {
      final input = valid.copyWith(years: 0);
      expect(() => CashFlowCalculator.build(input), throwsArgumentError);
    });

    test('interpreta coma y punto decimal', () {
      expect(InputValidator.parseNumber('12,5'), 12.5);
      expect(InputValidator.parseNumber(' 1000 '), 1000);
      expect(InputValidator.parseNumber('abc'), isNull);
      expect(InputValidator.parseNumber(''), isNull);
    });
  });
}
