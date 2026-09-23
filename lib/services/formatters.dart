/// Formato de números para mostrar en pantalla.
class Formatters {
  const Formatters._();

  /// Símbolo de moneda de los escenarios ficticios.
  static const String currencySymbol = 'S/';

  /// Monto redondeado con separador de miles, por ejemplo: S/ 12,345.
  static String money(double value) {
    final rounded = value.abs().round();
    final digits = rounded.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && remaining % 3 == 1) {
        buffer.write(',');
      }
    }
    final sign = value < 0 && rounded != 0 ? '-' : '';
    return '$sign$currencySymbol $buffer';
  }

  /// Porcentaje a partir de un decimal: 0.125 → "12.5 %".
  static String percent(double value, {int decimals = 1}) {
    return '${(value * 100).toStringAsFixed(decimals)} %';
  }

  /// Porcentaje opcional; si no existe muestra "No existe".
  static String optionalPercent(double? value) {
    if (value == null) {
      return 'No existe';
    }
    return percent(value);
  }

  /// Años con un decimal o "No se recupera".
  static String years(double? value) {
    if (value == null) {
      return 'No se recupera';
    }
    return '${value.toStringAsFixed(1)} años';
  }

  /// Número para rellenar un campo de texto sin decimales innecesarios.
  static String plain(double value) {
    final text = value.toStringAsFixed(2);
    if (text.endsWith('.00')) {
      return text.substring(0, text.length - 3);
    }
    if (text.endsWith('0')) {
      return text.substring(0, text.length - 1);
    }
    return text;
  }
}
