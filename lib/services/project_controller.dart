import 'package:flutter/foundation.dart';

import '../calculators/cash_flow_calculator.dart';
import '../calculators/indicator_calculator.dart';
import '../calculators/input_validator.dart';
import '../calculators/scenario_comparator.dart';
import '../models/cash_flow.dart';
import '../models/financial_indicators.dart';
import '../models/project_input.dart';
import '../models/scenario_result.dart';

/// Estado compartido del proyecto que el estudiante está analizando.
///
/// Todos los módulos leen el mismo proyecto, de modo que un cambio en
/// "Flujo de caja" se refleja en "Indicadores", "Riesgo" y "Analista".
class ProjectController extends ChangeNotifier {
  ProjectController({ProjectInput initial = ProjectInput.sample})
      : _input = initial {
    _recalculate();
  }

  ProjectInput _input;
  late CashFlow _cashFlow;
  late FinancialIndicators _indicators;
  late List<ScenarioResult> _scenarios;
  String _sourceLabel = 'Proyecto de ejemplo';

  ProjectInput get input => _input;
  CashFlow get cashFlow => _cashFlow;
  FinancialIndicators get indicators => _indicators;
  List<ScenarioResult> get scenarios => _scenarios;
  String get sourceLabel => _sourceLabel;

  /// Actualiza el proyecto. Devuelve los errores de validación, si hay.
  List<String> update(ProjectInput input, {String? sourceLabel}) {
    final errors = InputValidator.validate(input);
    if (errors.isNotEmpty) {
      return errors;
    }
    _input = input;
    if (sourceLabel != null) {
      _sourceLabel = sourceLabel;
    }
    _recalculate();
    notifyListeners();
    return const [];
  }

  void reset() {
    update(ProjectInput.sample, sourceLabel: 'Proyecto de ejemplo');
  }

  void _recalculate() {
    _cashFlow = CashFlowCalculator.build(_input);
    _indicators = IndicatorCalculator.fromCashFlow(
      _cashFlow,
      _input.adjustedDiscountRate,
    );
    _scenarios = ScenarioComparator.compare(_input);
  }
}
