import 'package:flutter/material.dart';

import '../models/risk_level.dart';
import '../models/scenario_type.dart';
import '../services/app_feedback.dart';
import '../services/financial_analyst.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final finance = FinanceColors.of(context);
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
              ButtonSegment(
                value: level,
                label: Text(level.label),
                icon: Icon(_riskIcon(level)),
              ),
          ],
          selected: {input.riskLevel},
          onSelectionChanged: (selection) {
            AppFeedback.instance.simulate();
            controller.update(input.copyWith(riskLevel: selection.first));
          },
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Container(
            key: ValueKey(input.riskLevel),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: finance.warningContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(input.riskLevel.description),
          ),
        ),
        const SectionTitle(
          'VAN por escenario',
          subtitle: 'Verde: crea valor. Rojo: destruye valor.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ScenarioBars(results: scenarios),
          ),
        ),
        const SectionTitle('Comparación de escenarios'),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingRowColor: WidgetStatePropertyAll(
                scheme.primary.withValues(alpha: 0.08),
              ),
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
                      DataCell(
                        Text(
                          Formatters.money(result.indicators.npv),
                          style: TextStyle(
                            color: result.indicators.isNpvPositive
                                ? finance.positive
                                : finance.negative,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(Formatters.optionalPercent(result.indicators.irr)),
                      ),
                      DataCell(
                        Text(
                          Formatters.percent(result.indicators.profitMargin),
                        ),
                      ),
                      DataCell(
                        Text(Formatters.years(result.indicators.paybackPeriod)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SectionTitle('Supuestos de cada escenario'),
        Card(
          child: Column(
            children: [
              for (final scenario in ScenarioType.values)
                ListTile(
                  leading: Icon(_scenarioIcon(scenario), color: scheme.primary),
                  title: Text(scenario.label),
                  subtitle: Text(scenario.description),
                ),
            ],
          ),
        ),
        const SectionTitle('Lectura del analista'),
        InsightCard(insight: insight),
        const SizedBox(height: 24),
      ],
    );
  }

  IconData _riskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.bajo:
        return Icons.shield_outlined;
      case RiskLevel.medio:
        return Icons.balance_rounded;
      case RiskLevel.alto:
        return Icons.bolt_rounded;
    }
  }

  IconData _scenarioIcon(ScenarioType scenario) {
    switch (scenario) {
      case ScenarioType.pesimista:
        return Icons.south_east_rounded;
      case ScenarioType.base:
        return Icons.east_rounded;
      case ScenarioType.optimista:
        return Icons.north_east_rounded;
    }
  }
}
