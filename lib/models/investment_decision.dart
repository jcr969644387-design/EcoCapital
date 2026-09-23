/// Decisiones posibles frente a un caso de inversión.
enum InvestmentDecision { invertir, noInvertir, revisar }

extension InvestmentDecisionDetails on InvestmentDecision {
  String get label {
    switch (this) {
      case InvestmentDecision.invertir:
        return 'Invertir';
      case InvestmentDecision.noInvertir:
        return 'No invertir';
      case InvestmentDecision.revisar:
        return 'Revisar el proyecto';
    }
  }
}
