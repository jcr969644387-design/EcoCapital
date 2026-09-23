import 'package:flutter/material.dart';

import '../models/viability.dart';
import '../services/app_feedback.dart';
import '../services/financial_analyst.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/insight_card.dart';
import '../widgets/motion.dart';
import '../widgets/project_summary_card.dart';
import '../widgets/section_title.dart';

/// Módulo 5: analista financiero local basado en reglas.
class AnalystScreen extends StatefulWidget {
  const AnalystScreen({super.key, required this.controller});

  final ProjectController controller;

  @override
  State<AnalystScreen> createState() => _AnalystScreenState();
}

class _AnalystScreenState extends State<AnalystScreen> {
  static const FinancialAnalyst _analyst = FinancialAnalyst();

  AnalystTopic _topic = AnalystTopic.van;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analista financiero')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Widget? child) {
    final controller = widget.controller;
    final input = controller.input;
    final indicators = controller.indicators;
    final scenarios = controller.scenarios;
    final viability = _analyst.verdict(scenarios);
    final answer = _analyst.answer(_topic, input, indicators, scenarios);
    final insights = _analyst.analyze(input, indicators, scenarios);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final verdictColor = _verdictColor(context, viability);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProjectSummaryCard(controller: controller),
        FadeSlideIn(
          child: Card(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    verdictColor.withValues(alpha: 0.16),
                    verdictColor.withValues(alpha: 0.04),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: verdictColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.psychology_alt_outlined,
                      color: verdictColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Veredicto educativo',
                          style: textTheme.labelLarge?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        AnimatedValueText(
                          viability.label,
                          style: textTheme.headlineSmall?.copyWith(
                            color: verdictColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _analyst.verdictMessage(viability),
                          style: const TextStyle(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SectionTitle(
          'Pregúntale al analista',
          subtitle: 'Elige una pregunta sobre tu proyecto.',
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final topic in AnalystTopic.values)
              ChoiceChip(
                label: Text(topic.question),
                selected: topic == _topic,
                onSelected: (_) {
                  AppFeedback.instance.select();
                  setState(() => _topic = topic);
                },
              ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SizeTransition(sizeFactor: animation, child: child),
          ),
          child: KeyedSubtree(
            key: ValueKey(_topic),
            child: InsightCard(insight: answer),
          ),
        ),
        const SectionTitle('Diagnóstico completo'),
        for (var i = 0; i < insights.length; i++)
          FadeSlideIn(index: i, child: InsightCard(insight: insights[i])),
        const SizedBox(height: 8),
        Text(
          'Este analista aplica reglas fijas y transparentes sobre tus '
          'cálculos. No usa inteligencia artificial externa ni internet, y '
          'no constituye asesoramiento financiero.',
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Color _verdictColor(BuildContext context, Viability viability) {
    final finance = FinanceColors.of(context);
    switch (viability) {
      case Viability.viable:
        return finance.positive;
      case Viability.viableConRiesgo:
      case Viability.revisar:
        return finance.warning;
      case Viability.noViable:
        return finance.negative;
    }
  }
}
