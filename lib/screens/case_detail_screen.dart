import 'package:flutter/material.dart';

import '../calculators/indicator_calculator.dart';
import '../calculators/scenario_comparator.dart';
import '../models/decision_case.dart';
import '../models/investment_decision.dart';
import '../models/risk_level.dart';
import '../services/app_feedback.dart';
import '../services/decision_evaluator.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/motion.dart';
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
    switch (feedback.outcome) {
      case DecisionOutcome.correcta:
        AppFeedback.instance.success();
        break;
      case DecisionOutcome.parcial:
        AppFeedback.instance.partial();
        break;
      case DecisionOutcome.incorrecta:
        AppFeedback.instance.error();
        break;
    }
    setState(() {
      _choice = choice;
      _feedback = feedback;
      _decidedWithoutAnalysis = !_showAnalysis;
    });
    widget.onEvaluated(widget.decisionCase.id, feedback);
  }

  void _retry() {
    AppFeedback.instance.tap();
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
    AppFeedback.instance.confirm();
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final feedback = _feedback;
    return Scaffold(
      appBar: AppBar(title: Text(decisionCase.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: Icon(
                  Icons.storefront_outlined,
                  size: 18,
                  color: scheme.primary,
                ),
                label: Text(decisionCase.sector),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              decisionCase.context,
              style: textTheme.bodyLarge?.copyWith(height: 1.4),
            ),
            const SectionTitle('Datos del proyecto'),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    _dataRow('Inversión inicial', input.initialInvestment),
                    _dataRow('Ingresos por año', input.annualIncome),
                    _dataRow('Costos por año', input.annualCost),
                    _textRow('Vida del proyecto', '${input.years} años'),
                    _textRow(
                      'Tasa base',
                      Formatters.percent(input.discountRate),
                    ),
                    _textRow('Nivel de riesgo', input.riskLevel.label),
                  ],
                ),
              ),
            ),
            Card(
              child: SwitchListTile(
                key: const ValueKey('switch_analysis'),
                secondary: Icon(Icons.insights_rounded, color: scheme.primary),
                title: const Text('Ver análisis financiero'),
                subtitle: const Text('Recomendado antes de decidir.'),
                value: _showAnalysis,
                onChanged: (value) {
                  AppFeedback.instance.select();
                  setState(() => _showAnalysis = value);
                },
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _showAnalysis ? _analysis() : const SizedBox.shrink(),
            ),
            const SectionTitle('Tu decisión'),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.94, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: feedback == null
                  ? Column(
                      key: const ValueKey('decision_options'),
                      children: _decisionButtons(),
                    )
                  : _feedbackCard(feedback),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _decisionButtons() {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return [
      for (final decision in InvestmentDecision.values)
        Card(
          child: Pressable(
            key: ValueKey('decision_${decision.name}'),
            cue: FeedbackCue.select,
            onTap: () => _decide(decision),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(_decisionIcon(decision), color: scheme.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(decision.label, style: textTheme.titleSmall),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
    ];
  }

  IconData _decisionIcon(InvestmentDecision decision) {
    switch (decision) {
      case InvestmentDecision.invertir:
        return Icons.trending_up_rounded;
      case InvestmentDecision.noInvertir:
        return Icons.block_rounded;
      case InvestmentDecision.revisar:
        return Icons.manage_search_rounded;
    }
  }

  Widget _analysis() {
    final finance = FinanceColors.of(context);
    final input = widget.decisionCase.input;
    final indicators = IndicatorCalculator.fromInput(input);
    final scenarios = ScenarioComparator.compare(input);
    final irr = indicators.irr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MetricGrid(
              children: [
                MetricCard(
                  label: 'VAN (base)',
                  value: Formatters.money(indicators.npv),
                  icon: Icons.account_balance_outlined,
                  color: indicators.isNpvPositive
                      ? finance.positive
                      : finance.negative,
                ),
                MetricCard(
                  label: 'TIR',
                  value: Formatters.optionalPercent(irr),
                  icon: Icons.speed_rounded,
                  color: irr != null && irr > indicators.discountRate
                      ? finance.positive
                      : finance.negative,
                ),
                MetricCard(
                  label: 'Tasa exigida con riesgo',
                  value: Formatters.percent(indicators.discountRate),
                  icon: Icons.percent_rounded,
                ),
                MetricCard(
                  label: 'Recuperación',
                  value: Formatters.years(indicators.paybackPeriod),
                  icon: Icons.hourglass_bottom_rounded,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'VAN por escenario:',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            ScenarioBars(results: scenarios),
          ],
        ),
      ),
    );
  }

  Widget _feedbackCard(DecisionFeedback feedback) {
    final finance = FinanceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    Color color;
    Color container;
    IconData icon;
    switch (feedback.outcome) {
      case DecisionOutcome.correcta:
        color = finance.positive;
        container = finance.positiveContainer;
        icon = Icons.verified_rounded;
        break;
      case DecisionOutcome.parcial:
        color = finance.warning;
        container = finance.warningContainer;
        icon = Icons.adjust_rounded;
        break;
      case DecisionOutcome.incorrecta:
        color = finance.negative;
        container = finance.negativeContainer;
        icon = Icons.error_outline_rounded;
        break;
    }
    final choice = _choice;
    return Card(
      key: const ValueKey('decision_feedback'),
      color: container,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.4, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) =>
                      Transform.scale(scale: scale, child: child),
                  child: Icon(icon, color: color, size: 36),
                ),
                const SizedBox(width: 12),
                if (choice != null)
                  Expanded(
                    child: Text(
                      'Elegiste: ${choice.label}',
                      style: textTheme.labelLarge,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              feedback.title,
              style: textTheme.titleMedium?.copyWith(color: color),
            ),
            const SizedBox(height: 8),
            Text(feedback.explanation, style: const TextStyle(height: 1.4)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(
                      alpha: 0.6,
                    ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Aprendizaje clave: ${feedback.lesson}',
                style: const TextStyle(height: 1.4),
              ),
            ),
            if (_decidedWithoutAnalysis)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Decidiste sin revisar el análisis. En la práctica '
                  'profesional, primero se calculan los indicadores.',
                ),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Intentar de nuevo'),
                ),
                FilledButton.icon(
                  onPressed: _exploreInSimulator,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Explorar en el simulador'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
