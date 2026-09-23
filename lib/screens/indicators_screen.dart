import 'package:flutter/material.dart';

import '../calculators/irr_calculator.dart';
import '../services/formatters.dart';
import '../services/indicator_glossary.dart';
import '../services/project_controller.dart';
import '../widgets/indicator_tile.dart';
import '../widgets/project_summary_card.dart';
import '../widgets/section_title.dart';

/// Módulo 2: indicadores de evaluación con explicación sencilla.
class IndicatorsScreen extends StatelessWidget {
  const IndicatorsScreen({super.key, required this.controller});

  final ProjectController controller;

  static const double maxSliderRate = 40;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicadores')),
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
    final ind = controller.indicators;
    final irr = ind.irr;
    final payback = ind.paybackPeriod;
    final discounted = ind.discountedPaybackPeriod;
    final years = ind.projectYears;
    final ratePercent = input.discountRate * 100;
    final sliderValue = ratePercent.clamp(0, maxSliderRate).toDouble();
    final signChanges = IrrCalculator.signChanges(controller.cashFlow.netFlows);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProjectSummaryCard(controller: controller),
        const SectionTitle(
          'Prueba de sensibilidad',
          subtitle: 'Mueve la tasa base y observa cómo cambian VAN y TIR.',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tasa base: ${Formatters.percent(input.discountRate)}'),
                Slider(
                  key: const ValueKey('rate_slider'),
                  value: sliderValue,
                  max: maxSliderRate,
                  divisions: 40,
                  label: '${sliderValue.round()} %',
                  onChanged: (value) {
                    controller.update(
                      input.copyWith(discountRate: value / 100),
                    );
                  },
                ),
                Text('VAN actual: ${Formatters.money(ind.npv)}'),
              ],
            ),
          ),
        ),
        const SectionTitle(
          'Resultados',
          subtitle: 'Toca cada indicador para ver qué significa.',
        ),
        IndicatorTile(
          name: 'VAN (valor actual neto)',
          value: Formatters.money(ind.npv),
          explanation: IndicatorGlossary.npv,
          isGood: ind.npv > 0,
        ),
        IndicatorTile(
          name: 'TIR (tasa interna de retorno)',
          value: Formatters.optionalPercent(irr),
          explanation: IndicatorGlossary.irr,
          isGood: irr != null && irr > ind.discountRate,
        ),
        IndicatorTile(
          name: 'Tasa de descuento usada',
          value: Formatters.percent(ind.discountRate),
          explanation: IndicatorGlossary.discountRate,
        ),
        IndicatorTile(
          name: 'Retorno acumulado',
          value: Formatters.percent(ind.cumulativeReturn),
          explanation: IndicatorGlossary.cumulativeReturn,
          isGood: ind.cumulativeReturn > 0,
        ),
        IndicatorTile(
          name: 'Periodo de recuperación',
          value: Formatters.years(payback),
          explanation: IndicatorGlossary.payback,
          isGood: payback != null && payback <= years,
        ),
        IndicatorTile(
          name: 'Recuperación descontada',
          value: Formatters.years(discounted),
          explanation: IndicatorGlossary.discountedPayback,
          isGood: discounted != null && discounted <= years,
        ),
        IndicatorTile(
          name: 'Margen de rentabilidad',
          value: Formatters.percent(ind.profitMargin),
          explanation: IndicatorGlossary.profitMargin,
          isGood: ind.profitMargin > 0,
        ),
        if (signChanges > 1)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Atención: los flujos cambian de signo más de una vez. En '
                'ese caso la TIR puede no ser única; decide con el VAN.',
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
