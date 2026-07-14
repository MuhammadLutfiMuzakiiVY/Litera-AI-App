import 'package:litera_ai_mobile/features/diagnostic_assessment/data/dtos/diagnostic_dtos.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_profile.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_question.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_session.dart';

extension DiagnosticOptionDtoMapper on DiagnosticOptionDto {
  DiagnosticOption toDomain() {
    return DiagnosticOption(id: id, label: label, body: body);
  }
}

extension DiagnosticQuestionDtoMapper on DiagnosticQuestionDto {
  DiagnosticQuestion toDomain() {
    return DiagnosticQuestion(
      id: id,
      conceptId: conceptId,
      difficulty: difficulty,
      stem: stem,
      options: options.map((option) => option.toDomain()).toList(),
    );
  }
}

extension DiagnosticSessionDtoMapper on DiagnosticSessionDto {
  DiagnosticSession toDomain() {
    return DiagnosticSession(
      id: id,
      status: status,
      questions: questions.map((question) => question.toDomain()).toList(),
    );
  }
}

extension DiagnosticProfileDtoMapper on DiagnosticProfileDto {
  DiagnosticProfile toDomain() {
    return DiagnosticProfile(
      literacyProfile: literacyProfile,
      numeracyProfile: numeracyProfile,
      confidence: confidence,
      modelVersion: modelVersion,
    );
  }
}

