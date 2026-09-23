import '../models/project_input.dart';
import '../models/scenario_result.dart';
import '../models/scenario_type.dart';
import '../models/viability.dart';
import 'indicator_calculator.dart';

/// Compara el mismo proyecto en los escenarios pesimista, base y optimista.
class ScenarioComparator {
  const ScenarioComparator._();

  static List<ScenarioResult> compare(ProjectInput input) {
    final results = <ScenarioResult>[];
    for (final scenario in ScenarioType.values) {
      final variant = input.copyWith(scenario: scenario);
      results.add(
        ScenarioResult(
          scenario: scenario,
          indicators: IndicatorCalculator.fromInput(variant),
        ),
      );
    }
    return results;
  }

  static ScenarioResult resultFor(
    List<ScenarioResult> results,
    ScenarioType scenario,
  ) {
    return results.firstWhere((result) => result.scenario == scenario);
  }

  /// Número de escenarios con VAN positivo.
  static int positiveCount(List<ScenarioResult> results) {
    return results.where((result) => result.indicators.isNpvPositive).length;
  }

  /// Diferencia entre el mejor y el peor VAN: una medida simple de riesgo.
  static double npvRange(List<ScenarioResult> results) {
    var minNpv = double.infinity;
    var maxNpv = double.negativeInfinity;
    for (final result in results) {
      final npv = result.indicators.npv;
      if (npv < minNpv) {
        minNpv = npv;
      }
      if (npv > maxNpv) {
        maxNpv = npv;
      }
    }
    return maxNpv - minNpv;
  }

  /// Veredicto educativo según cuántos escenarios tienen VAN positivo.
  static Viability viability(List<ScenarioResult> results) {
    final positives = positiveCount(results);
    final base = resultFor(results, ScenarioType.base).indicators;
    if (positives == results.length) {
      return Viability.viable;
    }
    if (positives == 0) {
      return Viability.noViable;
    }
    if (base.isNpvPositive) {
      return Viability.viableConRiesgo;
    }
    return Viability.revisar;
  }
}
