import 'cash_flow_row.dart';

/// Flujo de caja completo: el periodo 0 contiene la inversión inicial.
class CashFlow {
  const CashFlow(this.rows);

  final List<CashFlowRow> rows;

  List<double> get netFlows => [for (final row in rows) row.netFlow];

  List<double> get cumulativeFlows {
    return [for (final row in rows) row.cumulativeFlow];
  }

  List<double> get discountedFlows {
    return [for (final row in rows) row.discountedFlow];
  }

  double get totalIncome {
    var total = 0.0;
    for (final row in rows) {
      total += row.income;
    }
    return total;
  }

  double get totalCost {
    var total = 0.0;
    for (final row in rows) {
      total += row.cost;
    }
    return total;
  }
}
