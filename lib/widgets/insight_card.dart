import 'package:flutter/material.dart';

import '../services/financial_analyst.dart';

/// Mensaje del analista con color según su tono.
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final AnalystInsight insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    IconData icon = Icons.lightbulb_outline;
    Color color = scheme.primary;
    switch (insight.tone) {
      case InsightTone.positivo:
        icon = Icons.trending_up;
        color = Colors.green.shade700;
        break;
      case InsightTone.alerta:
        icon = Icons.error_outline;
        color = Colors.orange.shade800;
        break;
      case InsightTone.negativo:
        icon = Icons.trending_down;
        color = scheme.error;
        break;
      case InsightTone.neutral:
        break;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(insight.message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
