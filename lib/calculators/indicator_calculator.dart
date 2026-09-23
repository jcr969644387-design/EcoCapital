import '../models/cash_flow.dart';
import '../models/financial_indicators.dart';
import '../models/project_input.dart';
import 'cash_flow_calculator.dart';
import 'irr_calculator.dart';
import 'npv_calculator.dart';
import 'payback_calculator.dart';

/// Reúne todos los indicadores de evaluación de un proyecto.
class IndicatorCalculator {
  const IndicatorCalculator._();

  static FinancialIndicators fromInput(ProjectInput input) {
    final cashFlow = CashFlowCalculator.build(input);
    return fromCashFlow(cashFlow, input.adjustedDiscountRate);
  }

  static FinancialIndicators fromCashFlow(CashFlow cashFlow, double rate) {
    final flows = cashFlow.netFlows;
    final investment = -flows.first;
    var operatingTotal = 0.0;
    for (var t = 1; t < flows.length; t++) {
      operatingTotal += flows[t];
    }
    final income = cashFlow.totalIncome;
    final margin = income == 0 ? 0.0 : (income - cashFlow.totalCost) / income;
    return FinancialIndicators(
      npv: NpvCalculator.calculate(flows, rate),
      irr: IrrCalculator.calculate(flows),
      discountRate: rate,
      cumulativeReturn: (operatingTotal - investment) / investment,
      paybackPeriod: PaybackCalculator.simple(flows),
      discountedPaybackPeriod: PaybackCalculator.discounted(flows, rate),
      profitMargin: margin,
      projectYears: flows.length - 1,
    );
  }
}
