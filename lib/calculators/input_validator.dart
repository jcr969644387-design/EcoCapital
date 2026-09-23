import '../models/project_input.dart';

/// Reglas de validación de los datos de un proyecto.
class InputValidator {
  const InputValidator._();

  static const int minYears = 1;
  static const int maxYears = 30;
  static const double maxDiscountRate = 1.0;
  static const double maxGrowthRate = 0.5;

  /// Devuelve la lista de errores. Una lista vacía significa datos válidos.
  static List<String> validate(ProjectInput input) {
    final errors = <String>[];
    if (!input.initialInvestment.isFinite || input.initialInvestment <= 0) {
      errors.add('La inversión inicial debe ser mayor que cero.');
    }
    if (!input.annualIncome.isFinite || input.annualIncome < 0) {
      errors.add('Los ingresos no pueden ser negativos.');
    }
    if (!input.annualCost.isFinite || input.annualCost < 0) {
      errors.add('Los costos no pueden ser negativos.');
    }
    if (input.years < minYears || input.years > maxYears) {
      errors.add('La vida del proyecto debe estar entre 1 y 30 años.');
    }
    final rate = input.discountRate;
    if (!rate.isFinite || rate < 0 || rate > maxDiscountRate) {
      errors.add('La tasa de descuento debe estar entre 0 % y 100 %.');
    }
    final growth = input.incomeGrowthRate;
    if (!growth.isFinite || growth.abs() > maxGrowthRate) {
      errors.add('El crecimiento de ingresos debe estar entre -50 % y 50 %.');
    }
    return errors;
  }

  static bool isValid(ProjectInput input) => validate(input).isEmpty;

  /// Lanza [ArgumentError] si los datos no son válidos.
  static void ensureValid(ProjectInput input) {
    final errors = validate(input);
    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join(' '));
    }
  }

  /// Convierte texto a número. Acepta coma o punto decimal.
  /// Devuelve `null` si el texto no es un número válido.
  static double? parseNumber(String text) {
    final cleaned = text.trim().replaceAll(' ', '').replaceAll(',', '.');
    if (cleaned.isEmpty) {
      return null;
    }
    final value = double.tryParse(cleaned);
    if (value == null || !value.isFinite) {
      return null;
    }
    return value;
  }
}
