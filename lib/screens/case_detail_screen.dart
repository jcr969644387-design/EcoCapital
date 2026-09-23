import 'package:flutter/material.dart';

import '../calculators/indicator_calculator.dart';
import '../calculators/scenario_comparator.dart';
import '../models/decision_case.dart';
import '../models/investment_decision.dart';
import '../models/risk_level.dart';
import '../services/decision_evaluator.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../widgets/scenario_bars.dart';
import '../widgets/section_title.dart';
import 'cash_flow_screen.dart';

/// Detalle de un caso: datos, análisis opcional, decisión y feedback.
class CaseDetailScreen extends StatefulWidget {
  const CaseDetailScreen({
    super.key,
    required this.decisionCase,
    required this.controller,
    required this.onEvaluated,
  });

  final DecisionCase decisionCase;
  final ProjectController controller;
  final void Function(String caseId, DecisionFeedback feedback) onEvaluated;

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  static const DecisionEvaluator _evaluator = DecisionEvaluator();

  bool _showAnalysis = false;
  bool _decidedWithoutAnalysis = false;
  InvestmentDecision? _choice;
  DecisionFeedback? _feedback;

  void _decide(InvestmentDecision choice) {
    final feedback = _evaluator.evaluate(widget.decisionCase, choice);
    setState(() {
      _choice = choice;
      _feedback = feedback;
      _decidedWithoutAnalysis = !_showAnalysis;
    });
    widget.onEvaluated(widget.decisionCase.id, feedback);
  }

  void _retry() {
    setState(() {
      _choice = null;
      _feedback = null;
    });
  }

  void _exploreInSimulator() {
    final decisionCase = widget.decisionCase;
    widget.controller.update(
      decisionCase.input,
      sourceLabel: 'Caso: ${decisionCase.title}',
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CashFlowScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decisionCase = widget.decisionCase;
    final input = decisionCase.input;
    final textTheme = Theme.of(context).textTheme;
    final feedback = _feedback;
    return Scaffold(
      appBar: AppBar(title: Text(decisionCase.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(decisionCase.sector, style: textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(decisionCase.context),
            const SectionTitle('Datos del proyecto'),
            _dataRow('Inversión inicial', input.initialInvestment),
            _dataRow('Ingresos por año', input.annualIncome),
            _dataRow('Costos por año', input.annualCost),
            _textRow('Vida del proyecto', '${input.years} años'),
            _textRow('Tasa base', Formatters.percent(input.discountRate)),
            _textRow('Nivel de riesgo', input.riskLevel.label),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const ValueKey('switch_analysis'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Ver análisis financiero'),
              subtitle: const Text('Recomendado antes de decidir.'),
              value: _showAnalysis,
              onChanged: (value) => setState(() => _showAnalysis = value),
            ),
            if (_showAnalysis) _analysis(),
            const SectionTitle('Tu decisión'),
            if (feedback == null) ..._decisionButtons(),
            if (feedback != null) _feedbackCard(feedback),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _decisionButtons() {
    return [
      for (final decision in InvestmentDecision.values)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            key: ValueKey('decision_${decision.name}'),
            onPressed: () => _decide(decision),
            child: Text(decision.label),
          ),
        ),
    ];
  }

  Widget _analysis() {
    final input = widget.decisionCase.input;
    final indicators = IndicatorCalculator.fromInput(input);
    final scenarios = ScenarioComparator.compare(input);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VAN (base): ${Formatters.money(indicators.npv)}'),
            Text('TIR: ${Formatters.optionalPercent(indicators.irr)}'),
            Text(
              'Tasa exigida con riesgo: '
              '${Formatters.percent(indicators.discountRate)}',
            ),
            Text(
              'Recuperación: '
              '${Formatters.years(indicators.paybackPeriod)}',
            ),
            const SizedBox(height: 8),
            const Text('VAN por escenario:'),
            ScenarioBars(results: scenarios),
          ],
        ),
      ),
    );
  }

  Widget _feedbackCard(DecisionFeedback feedback) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = feedback.isCorrect
        ? scheme.primaryContainer
        : scheme.secondaryContainer;
    final choice = _choice;
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (choice != null) Text('Elegiste: ${choice.label}'),
            const SizedBox(height: 4),
            Text(feedback.title, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(feedback.explanation),
            const SizedBox(height: 8),
            Text('Aprendizaje clave: ${feedback.lesson}'),
            if (_decidedWithoutAnalysis)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Decidiste sin revisar el análisis. En la práctica '
                  'profesional, primero se calculan los indicadores.',
                ),
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _retry,
                  child: const Text('Intentar de nuevo'),
                ),
                FilledButton(
                  onPressed: _exploreInSimulator,
                  child: const Text('Explorar en el simulador'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, double value) {
    return _textRow(label, Formatters.money(value));
  }

  Widget _textRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
