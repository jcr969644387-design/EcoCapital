import 'package:flutter/material.dart';

import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../widgets/cash_flow_chart.dart';
import '../widgets/cash_flow_table.dart';
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
            ProjectForm(controller: controller),
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
    final cashFlow = controller.cashFlow;
    final indicators = controller.indicators;
    final lastCumulative = cashFlow.rows.last.cumulativeFlow;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(
          'Flujo neto y acumulado',
          subtitle: 'El año 0 es la inversión inicial (flujo negativo).',
        ),
        CashFlowChart(
          netFlows: cashFlow.netFlows,
          cumulativeFlows: cashFlow.cumulativeFlows,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acumulado final: ${Formatters.money(lastCumulative)}'),
                Text(
                  'Recuperación: '
                  '${Formatters.years(indicators.paybackPeriod)}',
                ),
                Text('VAN: ${Formatters.money(indicators.npv)}'),
              ],
            ),
          ),
        ),
        const SectionTitle(
          'Tabla del flujo de caja',
          subtitle: 'Desliza horizontalmente para ver todas las columnas.',
        ),
        CashFlowTable(cashFlow: cashFlow),
        const SectionTitle('¿Cómo leerlo?'),
        const Text(
          'Flujo neto = ingresos − costos del año. El acumulado suma los '
          'flujos desde el año 0: cuando pasa de negativo a positivo, la '
          'inversión se recuperó. El flujo descontado muestra cuánto vale '
          'hoy cada flujo futuro según la tasa exigida.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
