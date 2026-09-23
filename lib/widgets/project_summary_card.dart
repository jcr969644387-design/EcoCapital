import 'package:flutter/material.dart';

import '../models/risk_level.dart';
import '../models/scenario_type.dart';
import '../screens/cash_flow_screen.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';

/// Resumen del proyecto actual con acceso para editarlo.
class ProjectSummaryCard extends StatelessWidget {
  const ProjectSummaryCard({super.key, required this.controller});

  final ProjectController controller;

  @override
  Widget build(BuildContext context) {
    final input = controller.input;
    final textTheme = Theme.of(context).textTheme;
    final investment = Formatters.money(input.initialInvestment);
    final income = Formatters.money(input.annualIncome);
    final cost = Formatters.money(input.annualCost);
    final rate = Formatters.percent(input.discountRate);
    final premium = Formatters.percent(input.riskLevel.premium);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.sourceLabel, style: textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('Inversión: $investment · Vida: ${input.years} años'),
            Text('Ingresos/año: $income · Costos/año: $cost'),
            Text('Tasa base: $rate + prima por riesgo: $premium'),
            Text(
              'Escenario: ${input.scenario.label} · '
              'Riesgo: ${input.riskLevel.label}',
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modificar proyecto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CashFlowScreen(controller: controller),
      ),
    );
  }
}
