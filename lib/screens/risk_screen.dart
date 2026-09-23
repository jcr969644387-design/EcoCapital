import 'package:flutter/material.dart';

import '../models/risk_level.dart';
import '../models/scenario_type.dart';
import '../services/financial_analyst.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../widgets/insight_card.dart';
import '../widgets/project_summary_card.dart';
import '../widgets/scenario_bars.dart';
import '../widgets/section_title.dart';

/// Módulo 3: riesgo y comparación de escenarios.
class RiskScreen extends StatelessWidget {
  const RiskScreen({super.key, required this.controller});

  final ProjectController controller;

  static const FinancialAnalyst _analyst = FinancialAnalyst();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riesgo')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: _buildBody,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Widget? child) {
    final input = controller.input;
    final scenarios = controller.scenarios;
    final insight = _analyst.explainRisk(input, scenarios);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProjectSummaryCard(controller: controller),
        const SectionTitle(
          'Nivel de riesgo',
          subtitle: 'Más riesgo = mayor tasa exigida = menor VAN.',
        ),
        SegmentedButton<RiskLevel>(
          showSelectedIcon: false,
          segments: [
            for (final level in RiskLevel.values)
              ButtonSegment(value: level, label: Text(level.label)),
          ],
          selected: {input.riskLevel},
          onSelectionChanged: (selection) {
            controller.update(input.copyWith(riskLevel: selection.first));
          },
        ),
        const SizedBox(height: 6),
        Text(input.riskLevel.description),
        const SectionTitle(
          'VAN por escenario',
          subtitle: 'Verde: crea valor. Rojo: destruye valor.',
        ),
        ScenarioBars(results: scenarios),
        const SectionTitle('Comparación de escenarios'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('Escenario')),
              DataColumn(label: Text('VAN'), numeric: true),
              DataColumn(label: Text('TIR'), numeric: true),
              DataColumn(label: Text('Margen'), numeric: true),
              DataColumn(label: Text('Recuperación')),
            ],
            rows: [
              for (final result in scenarios)
                DataRow(
                  cells: [
                    DataCell(Text(result.scenario.label)),
                    DataCell(Text(Formatters.money(result.indicators.npv))),
                    DataCell(
                      Text(Formatters.optionalPercent(result.indicators.irr)),
                    ),
                    DataCell(
                      Text(Formatters.percent(result.indicators.profitMargin)),
                    ),
                    DataCell(
                      Text(Formatters.years(result.indicators.paybackPeriod)),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SectionTitle('Supuestos de cada escenario'),
        for (final scenario in ScenarioType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text('${scenario.label}: ${scenario.description}'),
          ),
        const SectionTitle('Lectura del analista'),
        InsightCard(insight: insight),
        const SizedBox(height: 24),
      ],
    );
  }
}
