import '../calculators/scenario_comparator.dart';
import '../models/decision_case.dart';
import '../models/investment_decision.dart';
import '../models/scenario_result.dart';
import '../models/viability.dart';
import 'financial_analyst.dart';

/// Nivel de acierto de una decisión.
enum DecisionOutcome { correcta, parcial, incorrecta }

/// Retroalimentación para el estudiante.
class DecisionFeedback {
  const DecisionFeedback({
    required this.outcome,
    required this.recommended,
    required this.title,
    required this.explanation,
    required this.lesson,
  });

  final DecisionOutcome outcome;
  final InvestmentDecision recommended;
  final String title;
  final String explanation;
  final String lesson;

  bool get isCorrect => outcome == DecisionOutcome.correcta;
}

/// Evalúa la decisión del estudiante con las mismas reglas del analista.
class DecisionEvaluator {
  const DecisionEvaluator({this.analyst = const FinancialAnalyst()});

  final FinancialAnalyst analyst;

  /// Decisión recomendada según la viabilidad educativa.
  InvestmentDecision recommendedFor(List<ScenarioResult> scenarios) {
    final viability = ScenarioComparator.viability(scenarios);
    switch (viability) {
      case Viability.viable:
        return InvestmentDecision.invertir;
      case Viability.noViable:
        return InvestmentDecision.noInvertir;
      case Viability.viableConRiesgo:
      case Viability.revisar:
        return InvestmentDecision.revisar;
    }
  }

  DecisionFeedback evaluate(
    DecisionCase decisionCase,
    InvestmentDecision choice,
  ) {
    final scenarios = ScenarioComparator.compare(decisionCase.input);
    final recommended = recommendedFor(scenarios);
    final viability = ScenarioComparator.viability(scenarios);
    final reason = analyst.verdictMessage(viability);
    final outcome = _outcome(choice, recommended);
    return DecisionFeedback(
      outcome: outcome,
      recommended: recommended,
      title: _title(outcome, recommended),
      explanation: reason,
      lesson: decisionCase.keyLesson,
    );
  }

  DecisionOutcome _outcome(
    InvestmentDecision choice,
    InvestmentDecision recommended,
  ) {
    if (choice == recommended) {
      return DecisionOutcome.correcta;
    }
    // Pedir revisión es prudente, pero no aprovecha la información.
    if (choice == InvestmentDecision.revisar) {
      return DecisionOutcome.parcial;
    }
    return DecisionOutcome.incorrecta;
  }

  String _title(DecisionOutcome outcome, InvestmentDecision recommended) {
    final label = recommended.label;
    switch (outcome) {
      case DecisionOutcome.correcta:
        return '¡Buena decisión! Lo recomendable era: $label.';
      case DecisionOutcome.parcial:
        return 'Decisión prudente, pero los datos permitían decidir: $label.';
      case DecisionOutcome.incorrecta:
        return 'Revisa tu análisis. Lo recomendable era: $label.';
    }
  }
}
