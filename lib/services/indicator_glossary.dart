/// Explicaciones en lenguaje sencillo de cada indicador.
class IndicatorGlossary {
  const IndicatorGlossary._();

  static const String npv =
      'El VAN trae todos los flujos futuros al valor de hoy usando la tasa '
      'de descuento y les resta la inversión. Si es positivo, el proyecto '
      'genera más valor del que exige el inversionista.';

  static const String irr =
      'La TIR es la tasa que hace que el VAN sea cero. Se compara con la '
      'tasa de descuento: si la TIR es mayor, el proyecto rinde más de lo '
      'exigido.';

  static const String cumulativeReturn =
      'Compara lo que el proyecto devuelve en total con lo invertido, sin '
      'considerar el valor del dinero en el tiempo. Es fácil de entender '
      'pero puede engañar en proyectos largos.';

  static const String payback =
      'Indica en cuántos años se recupera la inversión con los flujos sin '
      'descontar. Mide liquidez, no rentabilidad.';

  static const String discountedPayback =
      'Igual que el periodo de recuperación, pero con flujos descontados. '
      'Siempre es igual o mayor que el simple.';

  static const String profitMargin =
      'Porcentaje de los ingresos que queda después de cubrir los costos '
      'operativos. No incluye la inversión inicial.';

  static const String discountRate =
      'Es la rentabilidad mínima que exige el inversionista. Aquí incluye '
      'la tasa base más una prima según el nivel de riesgo.';
}
