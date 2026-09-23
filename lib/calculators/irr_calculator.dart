import 'npv_calculator.dart';

/// Tasa interna de retorno (TIR): la tasa que hace VAN = 0.
///
/// Se calcula por bisección, un método simple y estable.
class IrrCalculator {
  const IrrCalculator._();

  static const double _lowerBound = -0.99;
  static const double _upperLimit = 100.0;
  static const double _tolerance = 1e-9;
  static const int _maxIterations = 300;

  /// Devuelve la TIR en decimal o `null` si no existe una TIR única.
  static double? calculate(List<double> flows) {
    if (flows.length < 2) {
      throw ArgumentError('Se necesitan al menos dos flujos.');
    }
    final hasNegative = flows.any((flow) => flow < 0);
    final hasPositive = flows.any((flow) => flow > 0);
    if (!hasNegative || !hasPositive) {
      return null;
    }
    var low = _lowerBound;
    var high = 1.0;
    var npvLow = NpvCalculator.calculate(flows, low);
    var npvHigh = NpvCalculator.calculate(flows, high);
    while (npvLow * npvHigh > 0 && high < _upperLimit) {
      high *= 2;
      npvHigh = NpvCalculator.calculate(flows, high);
    }
    if (npvLow * npvHigh > 0) {
      return null;
    }
    for (var i = 0; i < _maxIterations; i++) {
      final mid = (low + high) / 2;
      final npvMid = NpvCalculator.calculate(flows, mid);
      if (npvMid.abs() < _tolerance || (high - low) / 2 < _tolerance) {
        return mid;
      }
      if (npvLow * npvMid < 0) {
        high = mid;
      } else {
        low = mid;
        npvLow = npvMid;
      }
    }
    return (low + high) / 2;
  }

  /// Cantidad de cambios de signo. Más de uno puede producir varias TIR.
  static int signChanges(List<double> flows) {
    var changes = 0;
    double? previous;
    for (final flow in flows) {
      if (flow == 0) {
        continue;
      }
      if (previous != null && (previous < 0) != (flow < 0)) {
        changes++;
      }
      previous = flow;
    }
    return changes;
  }
}
