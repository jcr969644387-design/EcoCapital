import 'dart:math' as math;

/// Valor actual neto (VAN).
///
/// VAN = Σ Ft / (1 + r)^t, con t = 0 … n. El flujo F0 es la inversión
/// (negativa).
class NpvCalculator {
  const NpvCalculator._();

  static double calculate(List<double> flows, double rate) {
    if (flows.isEmpty) {
      throw ArgumentError('Se necesita al menos un flujo.');
    }
    if (!rate.isFinite || rate <= -1) {
      throw ArgumentError('La tasa debe ser mayor que -100 %.');
    }
    var total = 0.0;
    for (var t = 0; t < flows.length; t++) {
      total += flows[t] / math.pow(1 + rate, t);
    }
    return total;
  }
}
