import 'package:flutter/material.dart';

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
    final good = isGood;
    IconData icon = Icons.info_outline;
    Color color = scheme.onSurfaceVariant;
    if (good != null && good) {
      icon = Icons.check_circle_outline;
      color = Colors.green.shade700;
    }
    if (good != null && !good) {
      icon = Icons.warning_amber_outlined;
      color = scheme.error;
    }
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: color),
        title: Text(name),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.centerLeft,
        children: [Text(explanation)],
      ),
    );
  }
}
