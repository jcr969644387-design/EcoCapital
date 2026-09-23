import 'financial_indicators.dart';
import 'scenario_type.dart';

/// Indicadores obtenidos para un escenario concreto.
class ScenarioResult {
  const ScenarioResult({required this.scenario, required this.indicators});

  final ScenarioType scenario;
  final FinancialIndicators indicators;
}
