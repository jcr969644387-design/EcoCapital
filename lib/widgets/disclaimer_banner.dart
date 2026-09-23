import 'package:flutter/material.dart';

/// Advertencia visible: la app es educativa, no asesoría financiera.
class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key});

  static const String text =
      'Aplicación exclusivamente educativa. Usa escenarios ficticios y no '
      'constituye asesoramiento financiero ni recomendación de inversión.';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.school_outlined, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
