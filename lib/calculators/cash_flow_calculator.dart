import 'dart:math' as math;

import '../models/cash_flow.dart';
import '../models/cash_flow_row.dart';
import '../models/project_input.dart';
import '../models/scenario_type.dart';
import 'input_validator.dart';

/// Construye el flujo de caja de un proyecto.
class CashFlowCalculator {
  const CashFlowCalculator._();

  /// Flujo neto de un periodo: ingresos − costos.
  static double netFlow(double income, double cost) => income - cost;

  /// Suma acumulada de una serie de flujos.
  static List<double> cumulativeFlows(List<double> flows) {
    final result = <double>[];
    var running = 0.0;
    for (final flow in flows) {
      running += flow;
      result.add(running);
    }
    return result;
  }

  /// Genera el flujo de caja aplicando escenario, crecimiento y riesgo.
  static CashFlow build(ProjectInput input) {
    InputValidator.ensureValid(input);
    final rate = input.adjustedDiscountRate;
    final incomeFactor = input.scenario.incomeFactor;
    final costFactor = input.scenario.costFactor;
    final rows = <CashFlowRow>[];
    var cumulative = -input.initialInvestment;
    rows.add(
      CashFlowRow(
        period: 0,
        income: 0,
        cost: 0,
        netFlow: -input.initialInvestment,
        cumulativeFlow: cumulative,
        discountedFlow: -input.initialInvestment,
      ),
    );
    for (var t = 1; t <= input.years; t++) {
      final growth = math.pow(1 + input.incomeGrowthRate, t - 1);
      final income = input.annualIncome * incomeFactor * growth;
      final cost = input.annualCost * costFactor;
      final net = netFlow(income, cost);
      cumulative += net;
      final discounted = net / math.pow(1 + rate, t);
      rows.add(
        CashFlowRow(
          period: t,
          income: income,
          cost: cost,
          netFlow: net,
          cumulativeFlow: cumulative,
          discountedFlow: discounted,
        ),
      );
    }
    return CashFlow(rows);
  }
}
