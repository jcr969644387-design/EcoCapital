import 'package:flutter/material.dart';

/// Título de sección con barra de acento y texto de apoyo opcional.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final help = subtitle;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 20,
            margin: const EdgeInsets.only(top: 2, right: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [scheme.primary, scheme.tertiary],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleMedium),
                if (help != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      help,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
