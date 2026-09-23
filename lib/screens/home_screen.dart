import 'package:flutter/material.dart';

import '../app.dart';
import '../models/risk_level.dart';
import '../models/viability.dart';
import '../services/app_feedback.dart';
import '../services/financial_analyst.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/module_card.dart';
import '../widgets/motion.dart';
import '../widgets/section_title.dart';
import 'analyst_screen.dart';
import 'cash_flow_screen.dart';
import 'decisions_screen.dart';
import 'indicators_screen.dart';
import 'risk_screen.dart';

/// Pantalla principal con acceso a los cinco módulos.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.controller});

  final ProjectController controller;

  @override
  Widget build(BuildContext context) {
    final finance = FinanceColors.of(context);
    final scheme = Theme.of(context).colorScheme;
    final modules = [
      ModuleCard(
        key: const ValueKey('module_cash_flow'),
        step: 1,
        title: 'Flujo de caja',
        subtitle: 'Construye el flujo neto y acumulado.',
        icon: Icons.account_balance_wallet_outlined,
        accent: scheme.primary,
        onTap: () => _open(context, CashFlowScreen(controller: controller)),
      ),
      ModuleCard(
        key: const ValueKey('module_indicators'),
        step: 2,
        title: 'Indicadores',
        subtitle: 'VAN, TIR, recuperación y rentabilidad.',
        icon: Icons.query_stats_rounded,
        accent: scheme.secondary,
        onTap: () => _open(context, IndicatorsScreen(controller: controller)),
      ),
      ModuleCard(
        key: const ValueKey('module_risk'),
        step: 3,
        title: 'Riesgo',
        subtitle: 'Compara escenarios pesimista, base y optimista.',
        icon: Icons.stacked_line_chart_rounded,
        accent: finance.warning,
        onTap: () => _open(context, RiskScreen(controller: controller)),
      ),
      ModuleCard(
        key: const ValueKey('module_decisions'),
        step: 4,
        title: 'Decisiones',
        subtitle: 'Casos ficticios: ¿invertir, no invertir o revisar?',
        icon: Icons.gavel_rounded,
        accent: finance.negative,
        onTap: () => _open(context, DecisionsScreen(controller: controller)),
      ),
      ModuleCard(
        key: const ValueKey('module_analyst'),
        step: 5,
        title: 'Analista financiero',
        subtitle: 'Explicaciones basadas en reglas, sin conexión.',
        icon: Icons.psychology_alt_outlined,
        accent: scheme.tertiary,
        onTap: () => _open(context, AnalystScreen(controller: controller)),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(EcoCapitalApp.appName),
        actions: [
          IconButton(
            key: const ValueKey('button_settings'),
            tooltip: 'Sonido y vibración',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showSettings(context),
          ),
          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            FadeSlideIn(
              child: ListenableBuilder(
                listenable: controller,
                builder: (context, _) => _HeroHeader(controller: controller),
              ),
            ),
            const SizedBox(height: 12),
            const FadeSlideIn(index: 1, child: DisclaimerBanner()),
            const FadeSlideIn(
              index: 2,
              child: SectionTitle(
                'Ruta de aprendizaje',
                subtitle: 'Todos los módulos trabajan sobre el mismo proyecto.',
              ),
            ),
            for (var i = 0; i < modules.length; i++)
              FadeSlideIn(index: i + 3, child: modules[i]),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  void _showSettings(BuildContext context) {
    AppFeedback.instance.tap();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const FeedbackSettingsSheet(),
    );
  }

  void _showAbout(BuildContext context) {
    AppFeedback.instance.tap();
    showAboutDialog(
      context: context,
      applicationName: EcoCapitalApp.appName,
      applicationVersion: EcoCapitalApp.version,
      children: const [
        Text(DisclaimerBanner.text),
        SizedBox(height: 8),
        Text('No usa datos personales, cuentas bancarias ni internet.'),
      ],
    );
  }
}

/// Cabecera con la marca y un resumen vivo del proyecto actual.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.controller});

  final ProjectController controller;

  static const FinancialAnalyst _analyst = FinancialAnalyst();

  @override
  Widget build(BuildContext context) {
    final finance = FinanceColors.of(context);
    final textTheme = Theme.of(context).textTheme;
    final indicators = controller.indicators;
    final viability = _analyst.verdict(controller.scenarios);
    const onHero = Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [finance.heroStart, finance.heroEnd],
        ),
        boxShadow: [
          BoxShadow(
            color: finance.heroStart.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: onHero.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    'assets/images/ecocapital_logo.png',
                    width: 48,
                    height: 48,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.show_chart,
                        size: 48,
                        color: onHero,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EcoCapitalApp.appName,
                      style: textTheme.headlineSmall?.copyWith(color: onHero),
                    ),
                    Text(
                      'Laboratorio de evaluación de inversiones',
                      style: textTheme.bodySmall?.copyWith(
                        color: onHero.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Aprende a evaluar inversiones con proyectos ficticios: '
            'flujo de caja, VAN, TIR y riesgo.',
            style: textTheme.bodyMedium?.copyWith(
              color: onHero.withValues(alpha: 0.92),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: onHero.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: onHero.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.sourceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelLarge?.copyWith(color: onHero),
                      ),
                    ),
                    _VerdictChip(viability: viability),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _HeroStat(
                      label: 'VAN',
                      value: Formatters.money(indicators.npv),
                    ),
                    _HeroStat(
                      label: 'TIR',
                      value: Formatters.optionalPercent(indicators.irr),
                    ),
                    _HeroStat(
                      label: 'Nivel de riesgo',
                      value: controller.input.riskLevel.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedValueText(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerdictChip extends StatelessWidget {
  const _VerdictChip({required this.viability});

  final Viability viability;

  @override
  Widget build(BuildContext context) {
    // El chip siempre es blanco sobre la cabecera: usa los tonos oscuros.
    const finance = FinanceColors.light;
    Color color;
    switch (viability) {
      case Viability.viable:
        color = finance.positive;
        break;
      case Viability.viableConRiesgo:
      case Viability.revisar:
        color = finance.warning;
        break;
      case Viability.noViable:
        color = finance.negative;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        viability.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

/// Ajustes de sonido y vibración con prueba inmediata.
class FeedbackSettingsSheet extends StatelessWidget {
  const FeedbackSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final feedback = AppFeedback.instance;
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sonido y vibración', style: textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Se activan al pulsar botones, elegir opciones, simular y '
              'responder los casos. La vibración depende de tu dispositivo '
              'y el sonido respeta el modo silencio.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: feedback.soundEnabled,
              builder: (context, enabled, _) => SwitchListTile(
                key: const ValueKey('switch_sound'),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.volume_up_rounded),
                title: const Text('Sonidos de interacción'),
                value: enabled,
                onChanged: feedback.setSoundEnabled,
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: feedback.hapticsEnabled,
              builder: (context, enabled, _) => SwitchListTile(
                key: const ValueKey('switch_haptics'),
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.vibration_rounded),
                title: const Text('Vibración (háptica)'),
                value: enabled,
                onChanged: feedback.setHapticsEnabled,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.touch_app_outlined, size: 18),
                  label: const Text('Probar pulsación'),
                  onPressed: feedback.tap,
                ),
                ActionChip(
                  avatar: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Probar acierto'),
                  onPressed: feedback.success,
                ),
                ActionChip(
                  avatar: const Icon(Icons.highlight_off, size: 18),
                  label: const Text('Probar error'),
                  onPressed: feedback.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
