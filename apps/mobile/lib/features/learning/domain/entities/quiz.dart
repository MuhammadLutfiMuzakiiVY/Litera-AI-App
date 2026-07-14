import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_question.dart';

class QuizSession {
  const QuizSession({
    required this.id,
    required this.moduleId,
    required this.difficulty,
    required this.questions,
  });

  final String id;
  final String moduleId;
  final String difficulty;
  final List<DiagnosticQuestion> questions;
}

class QuizEvaluation {
  const QuizEvaluation({
    required this.score,
    required this.mastery,
    required this.ddaDecision,
  });

  final double score;
  final List<ConceptMastery> mastery;
  final DdaDecision ddaDecision;
}

class ConceptMastery {
  const ConceptMastery({
    required this.conceptId,
    required this.masteryProbability,
    required this.confidence,
  });

  final String conceptId;
  final double masteryProbability;
  final double confidence;
}

class DdaDecision {
  const DdaDecision({
    required this.previousDifficulty,
    required this.nextDifficulty,
    required this.reasonCode,
    required this.explanation,
  });

  final String previousDifficulty;
  final String nextDifficulty;
  final String reasonCode;
  final String explanation;
}

