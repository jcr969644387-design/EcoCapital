import 'package:flutter/material.dart';

import '../models/scenario_result.dart';
import '../models/scenario_type.dart';
import '../services/formatters.dart';
import '../theme/app_theme.dart';

/// Barras horizontales animadas del VAN por escenario.
class ScenarioBars extends StatelessWidget {
  const ScenarioBars({super.key, required this.results});

  final List<ScenarioResult> results;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final finance = FinanceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    Color barColor(ScenarioResult result) =>
        result.indicators.isNpvPositive ? finance.positive : finance.negative;
    var maxAbs = 1.0;
    for (final result in results) {
      final npv = result.indicators.npv.abs();
      if (npv > maxAbs) {
        maxAbs = npv;
      }
    }
    return Column(
      children: [
        for (final result in results)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(
                    result.scenario.label,
                    style: textTheme.labelLarge,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 22,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.centerLeft,
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      widthFactor: result.indicators.npv.abs() / maxAbs,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              barColor(result).withValues(alpha: 0.7),
                              barColor(result),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 104,
                  child: Text(
                    Formatters.money(result.indicators.npv),
                    textAlign: TextAlign.end,
                    style: textTheme.labelLarge?.copyWith(
                      color: barColor(result),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
