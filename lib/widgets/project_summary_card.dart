import 'package:flutter/material.dart';

import '../models/risk_level.dart';
import '../models/scenario_type.dart';
import '../screens/cash_flow_screen.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';
import 'motion.dart';

/// Resumen del proyecto actual con acceso para editarlo.
class ProjectSummaryCard extends StatelessWidget {
  const ProjectSummaryCard({super.key, required this.controller});

  final ProjectController controller;

  @override
  Widget build(BuildContext context) {
    final input = controller.input;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final investment = Formatters.money(input.initialInvestment);
    final income = Formatters.money(input.annualIncome);
    final cost = Formatters.money(input.annualCost);
    final rate = Formatters.percent(input.discountRate);
    final premium = Formatters.percent(input.riskLevel.premium);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work_outline_rounded, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.sourceLabel,
                    style: textTheme.titleSmall,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => openScreen(
                    context,
                    CashFlowScreen(controller: controller),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Modificar proyecto'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(label: 'Inversión', value: investment),
                  _Pill(label: 'Vida', value: '${input.years} años'),
                  _Pill(label: 'Ingresos/año', value: income),
                  _Pill(label: 'Costos/año', value: cost),
                  _Pill(label: 'Tasa base', value: '$rate + $premium'),
                  _Pill(label: 'Escenario', value: input.scenario.label),
                  _Pill(label: 'Nivel de riesgo', value: input.riskLevel.label),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        style: textTheme.bodySmall,
      ),
    );
  }
}
