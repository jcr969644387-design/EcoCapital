import 'package:flutter/material.dart';

import '../calculators/input_validator.dart';
import '../models/project_input.dart';
import '../models/risk_level.dart';
import '../models/scenario_type.dart';
import '../services/formatters.dart';
import '../services/project_controller.dart';

/// Formulario para modificar los datos del proyecto.
class ProjectForm extends StatefulWidget {
  const ProjectForm({super.key, required this.controller});

  final ProjectController controller;

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final _investment = TextEditingController();
  final _income = TextEditingController();
  final _cost = TextEditingController();
  final _years = TextEditingController();
  final _rate = TextEditingController();
  final _growth = TextEditingController();
  ScenarioType _scenario = ScenarioType.base;
  RiskLevel _risk = RiskLevel.medio;
  List<String> _errors = const [];

  @override
  void initState() {
    super.initState();
    _loadFields();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _investment.dispose();
    _income.dispose();
    _cost.dispose();
    _years.dispose();
    _rate.dispose();
    _growth.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(_loadFields);
  }

  void _loadFields() {
    final input = widget.controller.input;
    _investment.text = Formatters.plain(input.initialInvestment);
    _income.text = Formatters.plain(input.annualIncome);
    _cost.text = Formatters.plain(input.annualCost);
    _years.text = '${input.years}';
    _rate.text = Formatters.plain(input.discountRate * 100);
    _growth.text = Formatters.plain(input.incomeGrowthRate * 100);
    _scenario = input.scenario;
    _risk = input.riskLevel;
  }

  void _submit() {
    final errors = <String>[];
    final investment = _read(_investment, 'Inversión inicial', errors);
    final income = _read(_income, 'Ingresos anuales', errors);
    final cost = _read(_cost, 'Costos anuales', errors);
    final years = _read(_years, 'Vida del proyecto', errors);
    final rate = _read(_rate, 'Tasa de descuento', errors);
    final growth = _read(_growth, 'Crecimiento de ingresos', errors);
    if (years != null && years != years.roundToDouble()) {
      errors.add('La vida del proyecto debe ser un número entero de años.');
    }
    if (errors.isNotEmpty) {
      setState(() => _errors = errors);
      return;
    }
    final input = ProjectInput(
      initialInvestment: investment!,
      annualIncome: income!,
      annualCost: cost!,
      years: years!.round(),
      discountRate: rate! / 100,
      incomeGrowthRate: growth! / 100,
      riskLevel: _risk,
      scenario: _scenario,
    );
    final validation = widget.controller.update(
      input,
      sourceLabel: 'Proyecto personalizado',
    );
    setState(() => _errors = validation);
    if (validation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proyecto recalculado.')),
      );
    }
  }

  double? _read(
    TextEditingController field,
    String label,
    List<String> errors,
  ) {
    final value = InputValidator.parseNumber(field.text);
    if (value == null) {
      errors.add('$label: ingresa un número válido.');
    }
    return value;
  }

  void _reset() {
    setState(() => _errors = const []);
    widget.controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(
          key: const ValueKey('field_investment'),
          controller: _investment,
          label: 'Inversión inicial',
          prefix: '${Formatters.currencySymbol} ',
        ),
        Row(
          children: [
            Expanded(
              child: _field(
                key: const ValueKey('field_income'),
                controller: _income,
                label: 'Ingresos por año',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                key: const ValueKey('field_cost'),
                controller: _cost,
                label: 'Costos por año',
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _field(
                key: const ValueKey('field_years'),
                controller: _years,
                label: 'Vida (años)',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                key: const ValueKey('field_rate'),
                controller: _rate,
                label: 'Tasa base',
                suffix: '%',
              ),
            ),
          ],
        ),
        _field(
          key: const ValueKey('field_growth'),
          controller: _growth,
          label: 'Crecimiento anual de ingresos',
          suffix: '%',
          signed: true,
        ),
        const SizedBox(height: 4),
        const Text('Escenario económico'),
        const SizedBox(height: 6),
        SegmentedButton<ScenarioType>(
          showSelectedIcon: false,
          segments: [
            for (final scenario in ScenarioType.values)
              ButtonSegment(value: scenario, label: Text(scenario.label)),
          ],
          selected: {_scenario},
          onSelectionChanged: (selection) {
            setState(() => _scenario = selection.first);
          },
        ),
        const SizedBox(height: 12),
        const Text('Nivel de riesgo'),
        const SizedBox(height: 6),
        SegmentedButton<RiskLevel>(
          showSelectedIcon: false,
          segments: [
            for (final level in RiskLevel.values)
              ButtonSegment(value: level, label: Text(level.label)),
          ],
          selected: {_risk},
          onSelectionChanged: (selection) {
            setState(() => _risk = selection.first);
          },
        ),
        const SizedBox(height: 4),
        Text(
          _risk.description,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_errors.isNotEmpty)
          Card(
            color: scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final error in _errors)
                    Text(
                      '• $error',
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('button_calculate'),
                onPressed: _submit,
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Calcular'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _reset,
              child: const Text('Ejemplo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _field({
    required Key key,
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
    bool signed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: key,
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(
          decimal: true,
          signed: signed,
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          isDense: true,
          labelText: label,
          prefixText: prefix,
          suffixText: suffix,
        ),
      ),
    );
  }
}
