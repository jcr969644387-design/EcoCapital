import 'dart:math' as math;

/// Periodo de recuperación de la inversión.
class PaybackCalculator {
  const PaybackCalculator._();

  /// Periodo de recuperación simple (flujos sin descontar), en años.
  ///
  /// Interpola dentro del año en que el acumulado se vuelve positivo.
  /// Devuelve `null` si la inversión no se recupera.
  static double? simple(List<double> flows) {
    if (flows.isEmpty) {
      throw ArgumentError('Se necesita al menos un flujo.');
    }
    var cumulative = flows.first;
    if (cumulative >= 0) {
      return 0;
    }
    for (var t = 1; t < flows.length; t++) {
      final previous = cumulative;
      cumulative += flows[t];
      if (cumulative >= 0) {
        final fraction = -previous / flows[t];
        return (t - 1).toDouble() + fraction;
      }
    }
    return null;
  }

  /// Periodo de recuperación descontado con la tasa [rate].
  static double? discounted(List<double> flows, double rate) {
    if (!rate.isFinite || rate <= -1) {
      throw ArgumentError('La tasa debe ser mayor que -100 %.');
    }
    final discountedFlows = <double>[];
    for (var t = 0; t < flows.length; t++) {
      discountedFlows.add(flows[t] / math.pow(1 + rate, t));
    }
    return simple(discountedFlows);
  }
}
