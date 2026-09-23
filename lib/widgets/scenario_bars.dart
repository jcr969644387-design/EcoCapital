import 'package:flutter/material.dart';

import '../models/scenario_result.dart';
import '../models/scenario_type.dart';
import '../services/formatters.dart';

/// Barras horizontales del VAN por escenario.
class ScenarioBars extends StatelessWidget {
  const ScenarioBars({super.key, required this.results});

  final List<ScenarioResult> results;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
                SizedBox(width: 84, child: Text(result.scenario.label)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: result.indicators.npv.abs() / maxAbs,
                      child: Container(
                        height: 18,
                        decoration: BoxDecoration(
                          color: result.indicators.isNpvPositive
                              ? Colors.green.shade600
                              : scheme.error,
                          borderRadius: BorderRadius.circular(4),
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
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
