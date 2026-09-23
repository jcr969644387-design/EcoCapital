import 'package:flutter/material.dart';

import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/cash_flow_table.dart';
import '../widgets/metric_card.dart';
import '../widgets/motion.dart';
import '../widgets/project_form.dart';
import '../widgets/section_title.dart';

/// Módulo 1: construcción del flujo de caja.
class CashFlowScreen extends StatelessWidget {
  const CashFlowScreen({super.key, required this.controller});

  final ProjectController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flujo de caja')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionTitle(
              'Datos del proyecto',
              subtitle: 'Modifica los valores y presiona Calcular.',
            ),
            FadeSlideIn(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ProjectForm(controller: controller),
                ),
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: _buildResults,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, Widget? child) {
    final finance = FinanceColors.of(context);
    final cashFlow = controller.cashFlow;
    final indicators = controller.indicators;
    final lastCumulative = cashFlow.rows.last.cumulativeFlow;
    final payback = indicators.paybackPeriod;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(
          'Resultados clave',
          subtitle: 'Se actualizan cada vez que recalculas el proyecto.',
        ),
        MetricGrid(
          children: [
            MetricCard(
              label: 'Acumulado final',
              value: Formatters.money(lastCumulative),
              icon: Icons.savings_outlined,
              color: finance.forValue(lastCumulative),
            ),
            MetricCard(
              label: 'Recuperación',
              value: Formatters.years(payback),
              icon: Icons.hourglass_bottom_rounded,
              color: payback == null ? finance.negative : null,
            ),
            MetricCard(
              label: 'VAN',
              value: Formatters.money(indicators.npv),
              icon: Icons.trending_up_rounded,
              color: indicators.isNpvPositive
                  ? finance.positive
                  : finance.negative,
            ),
          ],
        ),
        const SectionTitle(
          'Flujo neto y acumulado',
          subtitle: 'El año 0 es la inversión inicial (flujo negativo).',
        ),
        CashFlowChart(
          netFlows: cashFlow.netFlows,
          cumulativeFlows: cashFlow.cumulativeFlows,
        ),
        const SectionTitle(
          'Tabla del flujo de caja',
          subtitle: 'Desliza horizontalmente para ver todas las columnas.',
        ),
        CashFlowTable(cashFlow: cashFlow),
        const SectionTitle('¿Cómo leerlo?'),
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Flujo neto = ingresos − costos del año. El acumulado suma los '
              'flujos desde el año 0: cuando pasa de negativo a positivo, la '
              'inversión se recuperó. El flujo descontado muestra cuánto vale '
              'hoy cada flujo futuro según la tasa exigida.',
              style: TextStyle(height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
