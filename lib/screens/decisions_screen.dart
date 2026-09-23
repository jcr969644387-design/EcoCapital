import 'package:flutter/material.dart';

import '../models/decision_case.dart';
import '../services/case_repository.dart';
import '../services/decision_evaluator.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/motion.dart';
import '../widgets/section_title.dart';
import 'case_detail_screen.dart';

/// Módulo 4: casos ficticios para practicar decisiones de inversión.
class DecisionsScreen extends StatefulWidget {
  const DecisionsScreen({super.key, required this.controller});

  final ProjectController controller;

  @override
  State<DecisionsScreen> createState() => _DecisionsScreenState();
}

class _DecisionsScreenState extends State<DecisionsScreen> {
  static const CaseRepository _repository = CaseRepository();

  /// Resultado de cada caso en esta sesión (id del caso → resultado).
  final Map<String, DecisionOutcome> _results = {};

  int get _correct {
    var count = 0;
    for (final outcome in _results.values) {
      if (outcome == DecisionOutcome.correcta) {
        count++;
      }
    }
    return count;
  }

  void _onEvaluated(String caseId, DecisionFeedback feedback) {
    setState(() => _results[caseId] = feedback.outcome);
  }

  void _openCase(DecisionCase decisionCase) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CaseDetailScreen(
          decisionCase: decisionCase,
          controller: widget.controller,
          onEvaluated: _onEvaluated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cases = _repository.all();
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = cases.isEmpty ? 0.0 : _results.length / cases.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Decisiones')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Analiza cada caso y decide: invertir, no invertir o revisar '
              'el proyecto. Puedes ver el análisis antes de decidir.',
              style: textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.tertiary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.emoji_events_rounded,
                            color: scheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aciertos: $_correct de ${_results.length}',
                                style: textTheme.titleMedium,
                              ),
                              Text(
                                'Casos disponibles: ${cases.length}',
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: progress),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SectionTitle('Casos'),
            for (var i = 0; i < cases.length; i++)
              FadeSlideIn(
                index: i,
                child: Card(
                  child: Pressable(
                    onTap: () => _openCase(cases[i]),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          _statusIcon(_results[cases[i].id]),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cases[i].title,
                                  style: textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cases[i].sector,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(DecisionOutcome? outcome) {
    final finance = FinanceColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    var icon = Icons.radio_button_unchecked;
    var color = scheme.outline;
    if (outcome != null) {
      switch (outcome) {
        case DecisionOutcome.correcta:
          icon = Icons.check_circle_rounded;
          color = finance.positive;
          break;
        case DecisionOutcome.parcial:
          icon = Icons.adjust_rounded;
          color = finance.warning;
          break;
        case DecisionOutcome.incorrecta:
          icon = Icons.cancel_rounded;
          color = finance.negative;
          break;
      }
    }
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(icon, key: ValueKey(icon), color: color),
      ),
    );
  }
}
