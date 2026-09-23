import 'package:ecocapital/calculators/cash_flow_calculator.dart';
import 'package:ecocapital/models/project_input.dart';
import 'package:ecocapital/models/risk_level.dart';
import 'package:ecocapital/models/scenario_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const input = ProjectInput(
    initialInvestment: 1000,
    annualIncome: 700,
    annualCost: 300,
    years: 3,
    discountRate: 0.10,
    riskLevel: RiskLevel.bajo,
  );

  group('Flujo neto', () {
    test('es ingresos menos costos', () {
      expect(CashFlowCalculator.netFlow(700, 300), 400);
      expect(CashFlowCalculator.netFlow(200, 350), -150);
    });

    test('el periodo 0 contiene la inversión negativa', () {
      final flow = CashFlowCalculator.build(input);
      expect(flow.rows.length, 4);
      expect(flow.rows.first.netFlow, -1000);
      expect(flow.netFlows, [-1000, 400, 400, 400]);
    });

    test('aplica los factores del escenario pesimista', () {
      final pessimist = input.copyWith(scenario: ScenarioType.pesimista);
      final flow = CashFlowCalculator.build(pessimist);
      // 700 × 0.8 − 300 × 1.1 = 560 − 330 = 230
      expect(flow.rows[1].netFlow, closeTo(230, 1e-9));
    });

    test('aplica el crecimiento de ingresos', () {
      final growing = input.copyWith(incomeGrowthRate: 0.10);
      final flow = CashFlowCalculator.build(growing);
      expect(flow.rows[1].income, closeTo(700, 1e-9));
      expect(flow.rows[2].income, closeTo(770, 1e-9));
    });
  });

  group('Flujo acumulado', () {
    test('suma los flujos periodo a periodo', () {
      final result = CashFlowCalculator.cumulativeFlows([-1000, 400, 400]);
      expect(result, [-1000, -600, -200]);
    });

    test('coincide con la columna acumulada del flujo de caja', () {
      final flow = CashFlowCalculator.build(input);
      expect(flow.cumulativeFlows, [-1000, -600, -200, 200]);
    });

    test('el flujo descontado usa la tasa ajustada por riesgo', () {
      final flow = CashFlowCalculator.build(input);
      expect(flow.rows[1].discountedFlow, closeTo(400 / 1.1, 1e-9));
    });
  });
}
