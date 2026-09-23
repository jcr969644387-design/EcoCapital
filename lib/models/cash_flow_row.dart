/// Una fila del flujo de caja (un periodo).
class CashFlowRow {
  const CashFlowRow({
    required this.period,
    required this.income,
    required this.cost,
    required this.netFlow,
    required this.cumulativeFlow,
    required this.discountedFlow,
  });

  final int period;
  final double income;
  final double cost;
  final double netFlow;
  final double cumulativeFlow;
  final double discountedFlow;
}
