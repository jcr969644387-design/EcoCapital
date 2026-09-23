import 'package:flutter/material.dart';

import '../services/financial_analyst.dart';
import '../theme/app_theme.dart';

/// Mensaje del analista con color según su tono.
class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight});

  final AnalystInsight insight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = FinanceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    IconData icon = Icons.lightbulb_outline_rounded;
    Color color = scheme.secondary;
    switch (insight.tone) {
      case InsightTone.positivo:
        icon = Icons.trending_up_rounded;
        color = finance.positive;
        break;
      case InsightTone.alerta:
        icon = Icons.error_outline_rounded;
        color = finance.warning;
        break;
      case InsightTone.negativo:
        icon = Icons.trending_down_rounded;
        color = finance.negative;
        break;
      case InsightTone.neutral:
        break;
    }
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(insight.title, style: textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(insight.message, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
