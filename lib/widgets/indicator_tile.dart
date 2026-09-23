import 'package:flutter/material.dart';

import '../services/app_feedback.dart';
import '../theme/app_theme.dart';
import 'motion.dart';

/// Indicador con valor y explicación desplegable.
class IndicatorTile extends StatelessWidget {
  const IndicatorTile({
    super.key,
    required this.name,
    required this.value,
    required this.explanation,
    this.isGood,
  });

  final String name;
  final String value;
  final String explanation;

  /// `true` = favorable, `false` = desfavorable, `null` = neutro.
  final bool? isGood;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = FinanceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final good = isGood;
    IconData icon = Icons.info_outline_rounded;
    Color color = scheme.secondary;
    if (good != null && good) {
      icon = Icons.check_circle_rounded;
      color = finance.positive;
    }
    if (good != null && !good) {
      icon = Icons.warning_amber_rounded;
      color = finance.negative;
    }
    return Card(
      child: ExpansionTile(
        onExpansionChanged: (_) => AppFeedback.instance.select(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        subtitle: AnimatedValueText(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: good == null ? scheme.onSurface : color,
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(explanation, style: const TextStyle(height: 1.4)),
          ),
        ],
      ),
    );
  }
}
