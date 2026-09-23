import 'package:ecocapital/calculators/scenario_comparator.dart';
import 'package:ecocapital/models/project_input.dart';
import 'package:ecocapital/models/risk_level.dart';
import 'package:ecocapital/models/scenario_type.dart';
import 'package:ecocapital/models/viability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const input = ProjectInput(
    initialInvestment: 50000,
    annualIncome: 30000,
    annualCost: 15000,
    years: 5,
    discountRate: 0.10,
  );

  group('Comparación de escenarios', () {
    test('devuelve los tres escenarios en orden', () {
      final results = ScenarioComparator.compare(input);
      expect(results.map((r) => r.scenario).toList(), ScenarioType.values);
    });

    test('el VAN crece de pesimista a optimista', () {
      final results = ScenarioComparator.compare(input);
      final npvs = [for (final r in results) r.indicators.npv];
      expect(npvs[0], lessThan(npvs[1]));
      expect(npvs[1], lessThan(npvs[2]));
    });

    test('más riesgo reduce el VAN', () {
      final low = input.copyWith(riskLevel: RiskLevel.bajo);
      final high = input.copyWith(riskLevel: RiskLevel.alto);
      final lowBase = ScenarioComparator.resultFor(
        ScenarioComparator.compare(low),
        ScenarioType.base,
      );
      final highBase = ScenarioComparator.resultFor(
        ScenarioComparator.compare(high),
        ScenarioType.base,
      );
      expect(lowBase.indicators.npv, greaterThan(highBase.indicators.npv));
    });

    test('calcula el rango de VAN y los escenarios positivos', () {
      final results = ScenarioComparator.compare(input);
      expect(ScenarioComparator.npvRange(results), greaterThan(0));
      expect(ScenarioComparator.positiveCount(results), 2);
    });

    test('clasifica la viabilidad educativa', () {
      final results = ScenarioComparator.compare(input);
      expect(ScenarioComparator.viability(results), Viability.viableConRiesgo);
    });
  });
}
