import '../models/decision_case.dart';
import '../models/project_input.dart';
import '../models/risk_level.dart';

/// Casos ficticios para el módulo de decisiones.
///
/// Los datos son inventados con fines educativos y no representan
/// empresas, mercados ni oportunidades reales.
class CaseRepository {
  const CaseRepository();

  List<DecisionCase> all() => _cases;

  DecisionCase byId(String id) => _cases.firstWhere((c) => c.id == id);

  static const List<DecisionCase> _cases = [
    DecisionCase(
      id: 'panaderia',
      title: 'Panadería artesanal',
      sector: 'Alimentos',
      context: 'Una panadería de barrio quiere abrir un segundo local. Ya '
          'conoce a sus clientes y sus costos son estables.',
      input: ProjectInput(
        initialInvestment: 30000,
        annualIncome: 40000,
        annualCost: 22000,
        years: 6,
        discountRate: 0.10,
        riskLevel: RiskLevel.bajo,
      ),
      keyLesson: 'Un negocio conocido, con margen amplio y riesgo bajo, '
          'resiste incluso el escenario pesimista.',
    ),
    DecisionCase(
      id: 'celulares',
      title: 'Tienda de accesorios para celulares',
      sector: 'Comercio',
      context: 'Un emprendedor quiere abrir una tienda en un centro '
          'comercial nuevo. El alquiler es caro y la competencia es fuerte.',
      input: ProjectInput(
        initialInvestment: 80000,
        annualIncome: 50000,
        annualCost: 42000,
        years: 5,
        discountRate: 0.12,
        riskLevel: RiskLevel.alto,
      ),
      keyLesson: 'Si ni el escenario optimista logra un VAN positivo, el '
          'problema es estructural: margen muy bajo para tanta inversión.',
    ),
    DecisionCase(
      id: 'palta',
      title: 'Planta de empaque de palta',
      sector: 'Agroexportación',
      context: 'Una cooperativa evalúa una planta de empaque. Los precios '
          'internacionales cambian mucho de un año a otro.',
      input: ProjectInput(
        initialInvestment: 120000,
        annualIncome: 90000,
        annualCost: 60000,
        years: 6,
        discountRate: 0.11,
      ),
      keyLesson: 'Con VAN base casi nulo, el resultado depende del precio. '
          'Antes de decidir conviene renegociar costos o asegurar ventas.',
    ),
    DecisionCase(
      id: 'solar',
      title: 'Paneles solares comunitarios',
      sector: 'Energía',
      context: 'Una asociación vecinal instalará paneles solares y venderá '
          'energía a sus socios con un contrato de 10 años.',
      input: ProjectInput(
        initialInvestment: 60000,
        annualIncome: 20000,
        annualCost: 5000,
        years: 10,
        discountRate: 0.08,
        riskLevel: RiskLevel.bajo,
      ),
      keyLesson: 'Los proyectos largos y estables pueden tener una '
          'recuperación lenta y aun así un VAN claramente positivo.',
    ),
    DecisionCase(
      id: 'delivery',
      title: 'App de delivery universitario',
      sector: 'Tecnología',
      context: 'Un grupo de estudiantes quiere lanzar una app de delivery '
          'en su ciudad. La demanda es incierta y hay competidores grandes.',
      input: ProjectInput(
        initialInvestment: 25000,
        annualIncome: 45000,
        annualCost: 33000,
        years: 4,
        discountRate: 0.10,
        riskLevel: RiskLevel.alto,
      ),
      keyLesson: 'Una TIR atractiva en el escenario base no basta: en el '
          'pesimista el proyecto pierde dinero. El riesgo exige revisar.',
    ),
    DecisionCase(
      id: 'hotel',
      title: 'Hotel boutique',
      sector: 'Turismo',
      context: 'Un inversionista evalúa un hotel pequeño en una ciudad '
          'turística. La inversión es alta y el retorno es de largo plazo.',
      input: ProjectInput(
        initialInvestment: 200000,
        annualIncome: 70000,
        annualCost: 45000,
        years: 8,
        discountRate: 0.10,
      ),
      keyLesson: 'Tener ganancias contables no es suficiente: aun en el '
          'escenario optimista el VAN queda ligeramente negativo.',
    ),
  ];
}
