import 'package:flutter/material.dart';

import '../models/viability.dart';
import '../services/financial_analyst.dart';
import '../services/project_controller.dart';
import '../widgets/insight_card.dart';
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProjectSummaryCard(controller: controller),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Veredicto educativo', style: textTheme.labelLarge),
                Text(viability.label, style: textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(_analyst.verdictMessage(viability)),
              ],
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
                onSelected: (_) => setState(() => _topic = topic),
              ),
          ],
        ),
        const SizedBox(height: 8),
        InsightCard(insight: answer),
        const SectionTitle('Diagnóstico completo'),
        for (final insight in insights) InsightCard(insight: insight),
        const SizedBox(height: 8),
        Text(
          'Este analista aplica reglas fijas y transparentes sobre tus '
          'cálculos. No usa inteligencia artificial externa ni internet, y '
          'no constituye asesoramiento financiero.',
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
