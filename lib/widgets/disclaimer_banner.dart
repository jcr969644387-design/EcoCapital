import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Advertencia visible: la app es educativa, no asesoría financiera.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  static const String text =
      'Aplicación exclusivamente educativa. Usa escenarios ficticios y no '
      'constituye asesoramiento financiero ni recomendación de inversión.';

  @override
  Widget build(BuildContext context) {
    final finance = FinanceColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: finance.warningContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: finance.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.school_rounded, color: finance.warning, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
