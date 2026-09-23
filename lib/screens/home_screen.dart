import 'package:flutter/material.dart';

import '../app.dart';
import '../services/project_controller.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/module_card.dart';
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
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(EcoCapitalApp.appName),
        actions: [
          IconButton(
            tooltip: 'Acerca de',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/ecocapital_logo.png',
                    width: 56,
                    height: 56,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.show_chart, size: 56);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        EcoCapitalApp.appName,
                        style: textTheme.headlineSmall,
                      ),
                      const Text(
                        'Aprende a evaluar inversiones con proyectos '
                        'ficticios: flujo de caja, VAN, TIR y riesgo.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const DisclaimerBanner(),
            const SectionTitle(
              'Módulos',
              subtitle: 'Todos trabajan sobre el mismo proyecto.',
            ),
            ModuleCard(
              key: const ValueKey('module_cash_flow'),
              title: 'Flujo de caja',
              subtitle: 'Construye el flujo neto y acumulado.',
              icon: Icons.table_chart_outlined,
              onTap: () => _open(
                context,
                CashFlowScreen(controller: controller),
              ),
            ),
            ModuleCard(
              key: const ValueKey('module_indicators'),
              title: 'Indicadores',
              subtitle: 'VAN, TIR, recuperación y rentabilidad.',
              icon: Icons.analytics_outlined,
              onTap: () => _open(
                context,
                IndicatorsScreen(controller: controller),
              ),
            ),
            ModuleCard(
              key: const ValueKey('module_risk'),
              title: 'Riesgo',
              subtitle: 'Compara escenarios pesimista, base y optimista.',
              icon: Icons.stacked_line_chart,
              onTap: () => _open(
                context,
                RiskScreen(controller: controller),
              ),
            ),
            ModuleCard(
              key: const ValueKey('module_decisions'),
              title: 'Decisiones',
              subtitle: 'Casos ficticios: ¿invertir, no invertir o revisar?',
              icon: Icons.gavel_outlined,
              onTap: () => _open(
                context,
                DecisionsScreen(controller: controller),
              ),
            ),
            ModuleCard(
              key: const ValueKey('module_analyst'),
              title: 'Analista financiero',
              subtitle: 'Explicaciones basadas en reglas, sin conexión.',
              icon: Icons.support_agent_outlined,
              onTap: () => _open(
                context,
                AnalystScreen(controller: controller),
              ),
            ),
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

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: EcoCapitalApp.appName,
      applicationVersion: '1.0.0',
      children: const [
        Text(DisclaimerBanner.text),
        SizedBox(height: 8),
        Text('No usa datos personales, cuentas bancarias ni internet.'),
      ],
    );
  }
}
