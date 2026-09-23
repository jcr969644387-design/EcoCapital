/// Veredicto educativo de viabilidad según VAN y escenarios.
enum Viability { viable, viableConRiesgo, revisar, noViable }

extension ViabilityDetails on Viability {
  String get label {
    switch (this) {
      case Viability.viable:
        return 'Viable';
      case Viability.viableConRiesgo:
        return 'Viable con riesgo';
      case Viability.revisar:
        return 'Requiere revisión';
      case Viability.noViable:
        return 'No viable';
    }
  }
}
