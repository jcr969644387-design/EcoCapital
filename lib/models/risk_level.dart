/// Nivel de riesgo percibido del proyecto.
enum RiskLevel { bajo, medio, alto }

/// El riesgo se modela como una prima que se suma a la tasa de descuento:
/// a mayor riesgo, el inversionista exige mayor rentabilidad.
extension RiskLevelDetails on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.bajo:
        return 'Bajo';
      case RiskLevel.medio:
        return 'Medio';
      case RiskLevel.alto:
        return 'Alto';
    }
  }

  /// Prima por riesgo expresada en decimal (0.03 = 3 puntos).
  double get premium {
    switch (this) {
      case RiskLevel.bajo:
        return 0.0;
      case RiskLevel.medio:
        return 0.03;
      case RiskLevel.alto:
        return 0.06;
    }
  }

  String get description {
    switch (this) {
      case RiskLevel.bajo:
        return 'Mercado conocido y demanda estable. Sin prima adicional.';
      case RiskLevel.medio:
        return 'Algo de incertidumbre en ventas o costos. Prima de 3 puntos.';
      case RiskLevel.alto:
        return 'Mercado nuevo o muy volátil. Prima de 6 puntos.';
    }
  }
}
