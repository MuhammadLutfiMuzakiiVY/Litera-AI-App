import 'package:litera_ai_mobile/features/diagnostic_assessment/data/mappers/diagnostic_mapper.dart';
import 'package:litera_ai_mobile/features/learning/data/dtos/learning_dtos.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_module.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_path.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/quiz.dart';

extension LearningPathDtoMapper on LearningPathDto {
  LearningPath toDomain() {
    return LearningPath(
      id: id,
      status: status,
      items: items.map((item) => item.toDomain()).toList(),
    );
  }
}

extension LearningPathItemDtoMapper on LearningPathItemDto {
  LearningPathItem toDomain() {
    return LearningPathItem(
      id: id,
      conceptId: conceptId,
      moduleId: moduleId,
      title: title,
      targetDifficulty: targetDifficulty,
      status: status,
    );
  }
}

extension LearningModuleDtoMapper on LearningModuleDto {
  LearningModule toDomain() {
    return LearningModule(
      id: id,
      title: title,
      difficulty: difficulty,
      estimatedMinutes: estimatedMinutes,
      contents: contents.map((content) => content.toDomain()).toList(),
    );
  }
}

extension ModuleContentDtoMapper on ModuleContentDto {
  ModuleContent toDomain() {
    return ModuleContent(
      id: id,
      contentType: contentType,
      sortOrder: sortOrder,
      body: body,
      assetUrl: assetUrl,
    );
  }
}

extension QuizSessionDtoMapper on QuizSessionDto {
  QuizSession toDomain() {
    return QuizSession(
      id: id,
      moduleId: moduleId,
      difficulty: difficulty,
      questions: questions.map((question) => question.toDomain()).toList(),
    );
  }
}

extension QuizEvaluationDtoMapper on QuizEvaluationDto {
  QuizEvaluation toDomain() {
    return QuizEvaluation(
      score: score,
      mastery: mastery.map((item) => item.toDomain()).toList(),
      ddaDecision: ddaDecision.toDomain(),
    );
  }
}

extension ConceptMasteryDtoMapper on ConceptMasteryDto {
  ConceptMastery toDomain() {
    return ConceptMastery(
      conceptId: conceptId,
      masteryProbability: masteryProbability,
      confidence: confidence,
    );
  }
}

extension DdaDecisionDtoMapper on DdaDecisionDto {
  DdaDecision toDomain() {
    return DdaDecision(
      previousDifficulty: previousDifficulty,
      nextDifficulty: nextDifficulty,
      reasonCode: reasonCode,
      explanation: explanation,
    );
  }
}

