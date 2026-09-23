import 'package:flutter/material.dart';

import '../models/decision_case.dart';
import '../services/case_repository.dart';
import '../services/decision_evaluator.dart';
import '../services/project_controller.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Decisiones')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Analiza cada caso y decide: invertir, no invertir o revisar '
              'el proyecto. Puedes ver el análisis antes de decidir.',
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.emoji_events_outlined),
                title: Text('Aciertos: $_correct de ${_results.length}'),
                subtitle: Text('Casos disponibles: ${cases.length}'),
              ),
            ),
            const SectionTitle('Casos'),
            for (final decisionCase in cases)
              Card(
                child: ListTile(
                  leading: _statusIcon(_results[decisionCase.id]),
                  title: Text(decisionCase.title),
                  subtitle: Text(decisionCase.sector),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openCase(decisionCase),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(DecisionOutcome? outcome) {
    if (outcome == null) {
      return const Icon(Icons.radio_button_unchecked);
    }
    switch (outcome) {
      case DecisionOutcome.correcta:
        return Icon(Icons.check_circle, color: Colors.green.shade700);
      case DecisionOutcome.parcial:
        return Icon(Icons.adjust, color: Colors.orange.shade800);
      case DecisionOutcome.incorrecta:
        return Icon(Icons.cancel, color: Theme.of(context).colorScheme.error);
    }
  }
}
