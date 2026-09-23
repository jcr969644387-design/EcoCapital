/// Escenarios económicos que el estudiante puede analizar.
enum ScenarioType { pesimista, base, optimista }

/// Supuestos educativos de cada escenario.
///
/// Los factores multiplican los ingresos y costos del escenario base.
extension ScenarioTypeDetails on ScenarioType {
  String get label {
    switch (this) {
      case ScenarioType.pesimista:
        return 'Pesimista';
      case ScenarioType.base:
        return 'Base';
      case ScenarioType.optimista:
        return 'Optimista';
    }
  }

  double get incomeFactor {
    switch (this) {
      case ScenarioType.pesimista:
        return 0.80;
      case ScenarioType.base:
        return 1.00;
      case ScenarioType.optimista:
        return 1.20;
    }
  }

  double get costFactor {
    switch (this) {
      case ScenarioType.pesimista:
        return 1.10;
      case ScenarioType.base:
        return 1.00;
      case ScenarioType.optimista:
        return 0.95;
    }
  }

  String get description {
    switch (this) {
      case ScenarioType.pesimista:
        return 'Ingresos 20 % menores y costos 10 % mayores que el base.';
      case ScenarioType.base:
        return 'Ingresos y costos tal como fueron estimados.';
      case ScenarioType.optimista:
        return 'Ingresos 20 % mayores y costos 5 % menores que el base.';
    }
  }
}
