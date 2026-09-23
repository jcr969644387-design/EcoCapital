import 'package:flutter/material.dart';

import '../calculators/irr_calculator.dart';
import '../services/app_feedback.dart';
import '../services/formatters.dart';
import '../services/indicator_glossary.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/indicator_tile.dart';
import '../widgets/metric_card.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final finance = FinanceColors.of(context);
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.percent_rounded, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tasa base: ${Formatters.percent(input.discountRate)}',
                        style: textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
                Slider(
                  key: const ValueKey('rate_slider'),
                  value: sliderValue,
                  max: maxSliderRate,
                  divisions: 40,
                  label: '${sliderValue.round()} %',
                  onChanged: (value) {
                    if (value.round() != sliderValue.round()) {
                      AppFeedback.instance.select();
                    }
                    controller.update(
                      input.copyWith(discountRate: value / 100),
                    );
                  },
                  onChangeEnd: (_) => AppFeedback.instance.simulate(),
                ),
                MetricGrid(
                  children: [
                    MetricCard(
                      label: 'VAN actual',
                      value: Formatters.money(ind.npv),
                      icon: Icons.account_balance_outlined,
                      color: ind.isNpvPositive
                          ? finance.positive
                          : finance.negative,
                    ),
                    MetricCard(
                      label: 'TIR',
                      value: Formatters.optionalPercent(irr),
                      icon: Icons.speed_rounded,
                      color: irr != null && irr > ind.discountRate
                          ? finance.positive
                          : finance.negative,
                    ),
                  ],
                ),
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
          Card(
            color: finance.warningContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: finance.warning),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Atención: los flujos cambian de signo más de una vez. '
                      'En ese caso la TIR puede no ser única; decide con el '
                      'VAN.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}
