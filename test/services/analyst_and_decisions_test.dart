import 'package:ecocapital/calculators/indicator_calculator.dart';
import 'package:ecocapital/calculators/scenario_comparator.dart';
import 'package:ecocapital/models/investment_decision.dart';
import 'package:ecocapital/models/project_input.dart';
import 'package:ecocapital/services/case_repository.dart';
import 'package:ecocapital/services/decision_evaluator.dart';
import 'package:ecocapital/services/financial_analyst.dart';
import 'package:ecocapital/services/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const analyst = FinancialAnalyst();
  const evaluator = DecisionEvaluator();
  const repository = CaseRepository();

  group('Analista financiero local', () {
    test('genera un diagnóstico de seis puntos', () {
      const input = ProjectInput.sample;
      final indicators = IndicatorCalculator.fromInput(input);
      final scenarios = ScenarioComparator.compare(input);
      final insights = analyst.analyze(input, indicators, scenarios);
      expect(insights.length, 6);
    });

    test('explica un VAN negativo', () {
      final input = ProjectInput.sample.copyWith(annualIncome: 16000);
      final indicators = IndicatorCalculator.fromInput(input);
      final insight = analyst.explainNpv(indicators);
      expect(insight.tone, InsightTone.negativo);
      expect(insight.title, contains('negativo'));
    });

    test('responde a cada pregunta disponible', () {
      const input = ProjectInput.sample;
      final indicators = IndicatorCalculator.fromInput(input);
      final scenarios = ScenarioComparator.compare(input);
      for (final topic in AnalystTopic.values) {
        final answer = analyst.answer(topic, input, indicators, scenarios);
        expect(answer.message, isNotEmpty);
      }
    });
  });

  group('Casos de decisión', () {
    test('cada caso tiene la decisión recomendada esperada', () {
      final expected = {
        'panaderia': InvestmentDecision.invertir,
        'celulares': InvestmentDecision.noInvertir,
        'palta': InvestmentDecision.revisar,
        'solar': InvestmentDecision.invertir,
        'delivery': InvestmentDecision.revisar,
        'hotel': InvestmentDecision.noInvertir,
      };
      for (final decisionCase in repository.all()) {
        final scenarios = ScenarioComparator.compare(decisionCase.input);
        final recommended = evaluator.recommendedFor(scenarios);
        expect(recommended, expected[decisionCase.id], reason: decisionCase.id);
      }
    });

    test('evalúa decisiones correctas, parciales e incorrectas', () {
      final decisionCase = repository.byId('panaderia');
      final right = evaluator.evaluate(
        decisionCase,
        InvestmentDecision.invertir,
      );
      final partial = evaluator.evaluate(
        decisionCase,
        InvestmentDecision.revisar,
      );
      final wrong = evaluator.evaluate(
        decisionCase,
        InvestmentDecision.noInvertir,
      );
      expect(right.outcome, DecisionOutcome.correcta);
      expect(partial.outcome, DecisionOutcome.parcial);
      expect(wrong.outcome, DecisionOutcome.incorrecta);
    });
  });

  group('Formato', () {
    test('formatea montos y porcentajes', () {
      expect(Formatters.money(12345.4), 'S/ 12,345');
      expect(Formatters.money(-1500), '-S/ 1,500');
      expect(Formatters.percent(0.125), '12.5 %');
      expect(Formatters.years(null), 'No se recupera');
      expect(Formatters.plain(3.0000000000000004), '3');
      expect(Formatters.plain(12.5), '12.5');
    });
  });
}
