/// Resultado de los indicadores de evaluación de un proyecto.
class FinancialIndicators {
  const FinancialIndicators({
    required this.npv,
    required this.irr,
    required this.discountRate,
    required this.cumulativeReturn,
    required this.paybackPeriod,
    required this.discountedPaybackPeriod,
    required this.profitMargin,
    required this.projectYears,
  });

  /// Valor actual neto (VAN).
  final double npv;

  /// Tasa interna de retorno (TIR). Es `null` si no existe.
  final double? irr;

  /// Tasa de descuento usada (ya incluye la prima por riesgo).
  final double discountRate;

  /// (Suma de flujos operativos − inversión) / inversión, sin descontar.
  final double cumulativeReturn;

  /// Periodo de recuperación simple en años. `null` si no se recupera.
  final double? paybackPeriod;

  /// Periodo de recuperación descontado. `null` si no se recupera.
  final double? discountedPaybackPeriod;

  /// (Ingresos totales − costos totales) / ingresos totales.
  final double profitMargin;

  final int projectYears;

  bool get isNpvPositive => npv > 0;

  bool get hasIrr => irr != null;
}
