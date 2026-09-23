import 'package:ecocapital/calculators/irr_calculator.dart';
import 'package:ecocapital/calculators/npv_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VAN', () {
    test('es cero cuando la tasa es igual a la TIR', () {
      expect(NpvCalculator.calculate([-1000, 1100], 0.10), closeTo(0, 1e-9));
    });

    test('calcula un caso conocido', () {
      // −1000 + 400/1.1 + 400/1.21 + 400/1.331 ≈ −5.26
      final npv = NpvCalculator.calculate([-1000, 400, 400, 400], 0.10);
      expect(npv, closeTo(-5.2592, 1e-3));
    });

    test('disminuye cuando sube la tasa de descuento', () {
      final flows = [-1000.0, 500.0, 500.0, 500.0];
      final low = NpvCalculator.calculate(flows, 0.05);
      final high = NpvCalculator.calculate(flows, 0.15);
      expect(low, greaterThan(high));
    });

    test('rechaza flujos vacíos o tasas inválidas', () {
      expect(() => NpvCalculator.calculate([], 0.1), throwsArgumentError);
      expect(
        () => NpvCalculator.calculate([-100, 50], -1),
        throwsArgumentError,
      );
    });
  });

  group('TIR', () {
    test('un periodo: invertir 1000 y recibir 1100 da 10 %', () {
      final irr = IrrCalculator.calculate([-1000, 1100]);
      expect(irr, isNotNull);
      expect(irr!, closeTo(0.10, 1e-6));
    });

    test('dos periodos: −100, 60, 60 da ≈ 13.07 %', () {
      final irr = IrrCalculator.calculate([-100, 60, 60]);
      expect(irr!, closeTo(0.13066, 1e-4));
    });

    test('hace que el VAN sea cero', () {
      final flows = [-50000.0, 12000.0, 15000.0, 18000.0, 20000.0];
      final irr = IrrCalculator.calculate(flows)!;
      expect(NpvCalculator.calculate(flows, irr), closeTo(0, 1e-3));
    });

    test('no existe si todos los flujos son negativos', () {
      expect(IrrCalculator.calculate([-100, -10, -5]), isNull);
    });

    test('cuenta los cambios de signo', () {
      expect(IrrCalculator.signChanges([-100, 50, 60]), 1);
      expect(IrrCalculator.signChanges([-100, 230, -132]), 2);
    });
  });
}
