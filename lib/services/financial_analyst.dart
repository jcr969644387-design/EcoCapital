import '../calculators/indicator_calculator.dart';
import '../calculators/scenario_comparator.dart';
import '../models/financial_indicators.dart';
import '../models/project_input.dart';
import '../models/risk_level.dart';
import '../models/scenario_result.dart';
import '../models/scenario_type.dart';
import '../models/viability.dart';
import 'formatters.dart';

/// Tono de un mensaje del analista.
enum InsightTone { positivo, alerta, negativo, neutral }

/// Temas sobre los que el estudiante puede preguntar al analista.
enum AnalystTopic { van, tasa, tir, riesgo, rentabilidad }

extension AnalystTopicDetails on AnalystTopic {
  String get question {
    switch (this) {
      case AnalystTopic.van:
        return '¿Por qué el VAN es positivo o negativo?';
      case AnalystTopic.tasa:
        return '¿Cómo influye la tasa de descuento?';
      case AnalystTopic.tir:
        return '¿Qué significa esta TIR?';
      case AnalystTopic.riesgo:
        return '¿Cómo cambian los resultados con el riesgo?';
      case AnalystTopic.rentabilidad:
        return '¿Por qué es o no es rentable?';
    }
  }
}

/// Un mensaje explicativo del analista.
class AnalystInsight {
  const AnalystInsight({
    required this.title,
    required this.message,
    required this.tone,
  });

  final String title;
  final String message;
  final InsightTone tone;
}

/// Analista financiero local basado en reglas.
///
/// No usa inteligencia artificial ni conexión a internet: aplica reglas
/// explícitas y verificables sobre los indicadores calculados.
class FinancialAnalyst {
  const FinancialAnalyst();

  /// Puntos de la prueba de sensibilidad de la tasa (2 puntos = 0.02).
  static const double sensitivityStep = 0.02;

  /// Umbral para considerar "alta" una TIR frente a la tasa exigida.
  static const double highIrrSpread = 0.15;

  Viability verdict(List<ScenarioResult> scenarios) {
    return ScenarioComparator.viability(scenarios);
  }

  String verdictMessage(Viability viability) {
    switch (viability) {
      case Viability.viable:
        return 'El VAN es positivo en los tres escenarios. Desde el punto de '
            'vista educativo, el proyecto crea valor incluso si las cosas '
            'salen peor de lo esperado.';
      case Viability.viableConRiesgo:
        return 'El VAN es positivo en el escenario base, pero negativo en al '
            'menos un escenario. Conviene revisar supuestos o reducir el '
            'riesgo antes de decidir.';
      case Viability.revisar:
        return 'El VAN base no es positivo, aunque algún escenario sí lo es. '
            'El proyecto depende de condiciones favorables: revisa costos, '
            'precios o la inversión.';
      case Viability.noViable:
        return 'El VAN es negativo en todos los escenarios. Con estos datos, '
            'el proyecto destruye valor para el inversionista.';
    }
  }

  /// Diagnóstico completo del proyecto.
  List<AnalystInsight> analyze(
    ProjectInput input,
    FinancialIndicators indicators,
    List<ScenarioResult> scenarios,
  ) {
    return [
      explainNpv(indicators),
      explainDiscountRate(input, indicators),
      explainIrr(indicators),
      explainRisk(input, scenarios),
      explainPayback(indicators),
      explainProfitability(indicators),
    ];
  }

  /// Respuesta a una pregunta concreta del estudiante.
  AnalystInsight answer(
    AnalystTopic topic,
    ProjectInput input,
    FinancialIndicators indicators,
    List<ScenarioResult> scenarios,
  ) {
    switch (topic) {
      case AnalystTopic.van:
        return explainNpv(indicators);
      case AnalystTopic.tasa:
        return explainDiscountRate(input, indicators);
      case AnalystTopic.tir:
        return explainIrr(indicators);
      case AnalystTopic.riesgo:
        return explainRisk(input, scenarios);
      case AnalystTopic.rentabilidad:
        return explainProfitability(indicators);
    }
  }

  AnalystInsight explainNpv(FinancialIndicators indicators) {
    final npv = Formatters.money(indicators.npv);
    final rate = Formatters.percent(indicators.discountRate);
    if (indicators.npv > 0) {
      return AnalystInsight(
        title: 'VAN positivo: $npv',
        message: 'Al traer los flujos futuros a valor de hoy con una tasa de '
            '$rate, el proyecto recupera la inversión y además genera $npv '
            'extra. Crea valor por encima de la rentabilidad exigida.',
        tone: InsightTone.positivo,
      );
    }
    if (indicators.npv == 0) {
      return AnalystInsight(
        title: 'VAN igual a cero',
        message: 'El proyecto rinde exactamente la tasa exigida de $rate. '
            'No crea ni destruye valor.',
        tone: InsightTone.neutral,
      );
    }
    return AnalystInsight(
      title: 'VAN negativo: $npv',
      message: 'Los flujos futuros, descontados al $rate, no alcanzan para '
          'cubrir la inversión. Puede haber ganancias contables, pero no '
          'alcanzan la rentabilidad mínima exigida.',
      tone: InsightTone.negativo,
    );
  }

  AnalystInsight explainDiscountRate(
    ProjectInput input,
    FinancialIndicators indicators,
  ) {
    final higher = input.copyWith(
      discountRate: input.discountRate + sensitivityStep,
    );
    final higherNpv = IndicatorCalculator.fromInput(higher).npv;
    final base = Formatters.percent(input.discountRate);
    final premium = Formatters.percent(input.riskLevel.premium);
    final used = Formatters.percent(indicators.discountRate);
    final before = Formatters.money(indicators.npv);
    final after = Formatters.money(higherNpv);
    final flipped = indicators.npv > 0 && higherNpv <= 0;
    final extra = flipped
        ? ' Con solo 2 puntos más, el VAN deja de ser positivo: el '
            'proyecto es muy sensible a la tasa.'
        : '';
    return AnalystInsight(
      title: 'Tasa usada: $used',
      message: 'La tasa base es $base y se suma una prima por riesgo de '
          '$premium. Si la tasa subiera 2 puntos, el VAN pasaría de $before '
          'a $after, porque los flujos lejanos valen menos hoy.$extra',
      tone: flipped ? InsightTone.alerta : InsightTone.neutral,
    );
  }

  AnalystInsight explainIrr(FinancialIndicators indicators) {
    final irr = indicators.irr;
    final rate = Formatters.percent(indicators.discountRate);
    if (irr == null) {
      return const AnalystInsight(
        title: 'La TIR no existe',
        message: 'Los flujos nunca compensan la inversión o no cambian de '
            'signo, así que no hay una tasa que haga el VAN igual a cero. '
            'En estos casos se decide con el VAN.',
        tone: InsightTone.negativo,
      );
    }
    final irrText = Formatters.percent(irr);
    final spread = irr - indicators.discountRate;
    if (spread > highIrrSpread) {
      return AnalystInsight(
        title: 'TIR alta: $irrText',
        message: 'La TIR supera ampliamente la tasa exigida de $rate. Es una '
            'buena señal, pero una TIR alta no garantiza éxito: revisa si '
            'los supuestos de ingresos son realistas y compara con el VAN.',
        tone: InsightTone.positivo,
      );
    }
    if (spread > 0) {
      return AnalystInsight(
        title: 'TIR mayor que la tasa: $irrText',
        message: 'El proyecto rinde $irrText frente al $rate exigido. El '
            'margen de seguridad es moderado: pequeños cambios podrían '
            'reducirlo.',
        tone: InsightTone.positivo,
      );
    }
    return AnalystInsight(
      title: 'TIR baja: $irrText',
      message: 'La TIR es menor o igual que la tasa exigida de $rate. El '
          'proyecto no rinde lo suficiente para compensar el costo de '
          'oportunidad y el riesgo.',
      tone: InsightTone.negativo,
    );
  }

  AnalystInsight explainRisk(
    ProjectInput input,
    List<ScenarioResult> scenarios,
  ) {
    final positives = ScenarioComparator.positiveCount(scenarios);
    final range = Formatters.money(ScenarioComparator.npvRange(scenarios));
    final pessimist = ScenarioComparator.resultFor(
      scenarios,
      ScenarioType.pesimista,
    );
    final worst = Formatters.money(pessimist.indicators.npv);
    final level = input.riskLevel.label.toLowerCase();
    final message = 'Con riesgo $level, el VAN es positivo en $positives de '
        '${scenarios.length} escenarios. En el pesimista el VAN sería '
        '$worst. La distancia entre el mejor y el peor VAN es $range: '
        'cuanto mayor es, más incierto es el resultado.';
    return AnalystInsight(
      title: 'Riesgo: $positives de ${scenarios.length} escenarios positivos',
      message: message,
      tone: positives == scenarios.length
          ? InsightTone.positivo
          : InsightTone.alerta,
    );
  }

  AnalystInsight explainPayback(FinancialIndicators indicators) {
    final payback = indicators.paybackPeriod;
    final years = indicators.projectYears;
    if (payback == null) {
      return AnalystInsight(
        title: 'La inversión no se recupera',
        message: 'En los $years años del proyecto, la suma de flujos no '
            'alcanza a devolver la inversión inicial.',
        tone: InsightTone.negativo,
      );
    }
    final text = Formatters.years(payback);
    final isLate = payback > years * 0.7;
    return AnalystInsight(
      title: 'Recuperación en $text',
      message: isLate
          ? 'La inversión se recupera tarde, cerca del final de la vida del '
              'proyecto. Hay poco margen si los ingresos se retrasan.'
          : 'La inversión se recupera con margen antes del final del '
              'proyecto. Recuerda que esto mide liquidez, no rentabilidad.',
      tone: isLate ? InsightTone.alerta : InsightTone.positivo,
    );
  }

  AnalystInsight explainProfitability(FinancialIndicators indicators) {
    final margin = Formatters.percent(indicators.profitMargin);
    final roi = Formatters.percent(indicators.cumulativeReturn);
    if (indicators.cumulativeReturn > 0 && indicators.npv <= 0) {
      return AnalystInsight(
        title: 'Ganancia contable, pero no rentable',
        message: 'El retorno acumulado es $roi y el margen $margin, pero el '
            'VAN es negativo. Ganar dinero no basta: el proyecto debe rendir '
            'más que la tasa exigida, considerando el tiempo y el riesgo.',
        tone: InsightTone.alerta,
      );
    }
    if (indicators.npv > 0) {
      return AnalystInsight(
        title: 'Rentable según el VAN',
        message: 'El margen operativo es $margin y el retorno acumulado '
            '$roi. Como el VAN es positivo, la rentabilidad supera el '
            'costo de oportunidad del dinero.',
        tone: InsightTone.positivo,
      );
    }
    return AnalystInsight(
      title: 'No rentable',
      message: 'El margen operativo es $margin y el retorno acumulado $roi. '
          'Los flujos no alcanzan para recuperar la inversión con la '
          'rentabilidad exigida.',
      tone: InsightTone.negativo,
    );
  }
}
