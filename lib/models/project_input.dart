import 'risk_level.dart';
import 'scenario_type.dart';

/// Datos de un proyecto de inversión ficticio.
///
/// Las tasas se guardan en decimal: 0.10 equivale a 10 %.
class ProjectInput {
  const ProjectInput({
    required this.initialInvestment,
    required this.annualIncome,
    required this.annualCost,
    required this.years,
    required this.discountRate,
    this.incomeGrowthRate = 0,
    this.riskLevel = RiskLevel.medio,
    this.scenario = ScenarioType.base,
  });

  /// Proyecto de ejemplo con el que inicia la aplicación.
  static const ProjectInput sample = ProjectInput(
    initialInvestment: 50000,
    annualIncome: 30000,
    annualCost: 15000,
    years: 5,
    discountRate: 0.10,
    incomeGrowthRate: 0.03,
  );

  final double initialInvestment;
  final double annualIncome;
  final double annualCost;
  final int years;
  final double discountRate;
  final double incomeGrowthRate;
  final RiskLevel riskLevel;
  final ScenarioType scenario;

  /// Tasa que realmente se usa para descontar: tasa base + prima por riesgo.
  double get adjustedDiscountRate => discountRate + riskLevel.premium;

  ProjectInput copyWith({
    double? initialInvestment,
    double? annualIncome,
    double? annualCost,
    int? years,
    double? discountRate,
    double? incomeGrowthRate,
    RiskLevel? riskLevel,
    ScenarioType? scenario,
  }) {
    return ProjectInput(
      initialInvestment: initialInvestment ?? this.initialInvestment,
      annualIncome: annualIncome ?? this.annualIncome,
      annualCost: annualCost ?? this.annualCost,
      years: years ?? this.years,
      discountRate: discountRate ?? this.discountRate,
      incomeGrowthRate: incomeGrowthRate ?? this.incomeGrowthRate,
      riskLevel: riskLevel ?? this.riskLevel,
      scenario: scenario ?? this.scenario,
    );
  }
}
