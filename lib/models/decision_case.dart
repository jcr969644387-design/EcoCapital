import 'project_input.dart';

/// Caso ficticio para practicar la toma de decisiones de inversión.
class DecisionCase {
  const DecisionCase({
    required this.id,
    required this.title,
    required this.sector,
    required this.context,
    required this.input,
    required this.keyLesson,
  });

  final String id;
  final String title;
  final String sector;
  final String context;
  final ProjectInput input;

  /// Aprendizaje principal que deja el caso.
  final String keyLesson;
}
