import 'package:ecocapital/calculators/payback_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Periodo de recuperación', () {
    test('interpola dentro del año de recuperación', () {
      // Acumulado: −600, −200, +200 → 2 + 200/400 = 2.5 años
      final payback = PaybackCalculator.simple([-1000, 400, 400, 400]);
      expect(payback, closeTo(2.5, 1e-9));
    });

    test('recuperación exacta al final de un año', () {
      expect(PaybackCalculator.simple([-1000, 500, 500]), closeTo(2, 1e-9));
    });

    test('devuelve null si nunca se recupera', () {
      expect(PaybackCalculator.simple([-1000, 100, 100]), isNull);
    });

    test('el descontado es mayor o igual que el simple', () {
      final flows = [-1000.0, 400.0, 400.0, 400.0, 400.0];
      final simple = PaybackCalculator.simple(flows)!;
      final discounted = PaybackCalculator.discounted(flows, 0.10)!;
      expect(discounted, greaterThanOrEqualTo(simple));
    });
  });
}
