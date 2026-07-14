import 'package:litera_ai_mobile/features/diagnostic_assessment/data/dtos/diagnostic_dtos.dart';

class LearningPathDto {
  const LearningPathDto({
    required this.id,
    required this.status,
    required this.items,
  });

  factory LearningPathDto.fromJson(Map<String, Object?> json) {
    final items = json['items'] as List? ?? const [];
    return LearningPathDto(
      id: json['id'] as String,
      status: json['status'] as String,
      items: items
          .whereType<Map<String, Object?>>()
          .map(LearningPathItemDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String status;
  final List<LearningPathItemDto> items;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class LearningPathItemDto {
  const LearningPathItemDto({
    required this.id,
    required this.conceptId,
    required this.moduleId,
    required this.title,
    required this.targetDifficulty,
    required this.status,
  });

  factory LearningPathItemDto.fromJson(Map<String, Object?> json) {
    return LearningPathItemDto(
      id: json['id'] as String,
      conceptId: json['concept_id'] as String? ?? json['conceptId'] as String,
      moduleId: json['module_id'] as String? ?? json['moduleId'] as String,
      title: json['title'] as String,
      targetDifficulty: json['target_difficulty'] as String? ??
          json['targetDifficulty'] as String,
      status: json['status'] as String,
    );
  }

  final String id;
  final String conceptId;
  final String moduleId;
  final String title;
  final String targetDifficulty;
  final String status;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'concept_id': conceptId,
      'module_id': moduleId,
      'title': title,
      'target_difficulty': targetDifficulty,
      'status': status,
    };
  }
}

class LearningModuleDto {
  const LearningModuleDto({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.contents,
  });

  factory LearningModuleDto.fromJson(Map<String, Object?> json) {
    final contents = json['contents'] as List? ?? const [];
    return LearningModuleDto(
      id: json['id'] as String,
      title: json['title'] as String,
      difficulty: json['difficulty'] as String,
      estimatedMinutes:
          json['estimated_minutes'] as int? ?? json['estimatedMinutes'] as int,
      contents: contents
          .whereType<Map<String, Object?>>()
          .map(ModuleContentDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String title;
  final String difficulty;
  final int estimatedMinutes;
  final List<ModuleContentDto> contents;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'difficulty': difficulty,
      'estimated_minutes': estimatedMinutes,
      'contents': contents.map((content) => content.toJson()).toList(),
    };
  }
}

class ModuleContentDto {
  const ModuleContentDto({
    required this.id,
    required this.contentType,
    required this.sortOrder,
    required this.body,
    this.assetUrl,
  });

  factory ModuleContentDto.fromJson(Map<String, Object?> json) {
    return ModuleContentDto(
      id: json['id'] as String,
      contentType: json['content_type'] as String? ?? json['contentType'] as String,
      sortOrder: json['sort_order'] as int? ?? json['sortOrder'] as int,
      body: json['body'] as Map<String, Object?>,
      assetUrl: json['asset_url'] as String? ?? json['assetUrl'] as String?,
    );
  }

  final String id;
  final String contentType;
  final int sortOrder;
  final Map<String, Object?> body;
  final String? assetUrl;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'content_type': contentType,
      'sort_order': sortOrder,
      'body': body,
      'asset_url': assetUrl,
    };
  }
}

class QuizSessionDto {
  const QuizSessionDto({
    required this.id,
    required this.moduleId,
    required this.difficulty,
    required this.questions,
  });

  factory QuizSessionDto.fromJson(Map<String, Object?> json) {
    final questions = json['questions'] as List? ?? const [];
    return QuizSessionDto(
      id: json['id'] as String,
      moduleId: json['module_id'] as String? ?? json['moduleId'] as String,
      difficulty: json['difficulty'] as String,
      questions: questions
          .whereType<Map<String, Object?>>()
          .map(DiagnosticQuestionDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String moduleId;
  final String difficulty;
  final List<DiagnosticQuestionDto> questions;
}

class QuizEvaluationDto {
  const QuizEvaluationDto({
    required this.score,
    required this.mastery,
    required this.ddaDecision,
  });

  factory QuizEvaluationDto.fromJson(Map<String, Object?> json) {
    final mastery = json['mastery'] as List? ?? const [];
    return QuizEvaluationDto(
      score: (json['score'] as num).toDouble(),
      mastery: mastery
          .whereType<Map<String, Object?>>()
          .map(ConceptMasteryDto.fromJson)
          .toList(),
      ddaDecision: DdaDecisionDto.fromJson(
        json['dda_decision'] as Map<String, Object?>? ??
            json['ddaDecision'] as Map<String, Object?>,
      ),
    );
  }

  final double score;
  final List<ConceptMasteryDto> mastery;
  final DdaDecisionDto ddaDecision;
}

class ConceptMasteryDto {
  const ConceptMasteryDto({
    required this.conceptId,
    required this.masteryProbability,
    required this.confidence,
  });

  factory ConceptMasteryDto.fromJson(Map<String, Object?> json) {
    return ConceptMasteryDto(
      conceptId: json['concept_id'] as String? ?? json['conceptId'] as String,
      masteryProbability: (json['mastery_probability'] as num? ??
              json['masteryProbability'] as num)
          .toDouble(),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  final String conceptId;
  final double masteryProbability;
  final double confidence;
}

class DdaDecisionDto {
  const DdaDecisionDto({
    required this.previousDifficulty,
    required this.nextDifficulty,
    required this.reasonCode,
    required this.explanation,
  });

  factory DdaDecisionDto.fromJson(Map<String, Object?> json) {
    return DdaDecisionDto(
      previousDifficulty: json['previous_difficulty'] as String? ??
          json['previousDifficulty'] as String,
      nextDifficulty:
          json['next_difficulty'] as String? ?? json['nextDifficulty'] as String,
      reasonCode: json['reason_code'] as String? ?? json['reasonCode'] as String,
      explanation: json['explanation'] as String,
    );
  }

  final String previousDifficulty;
  final String nextDifficulty;
  final String reasonCode;
  final String explanation;
}
