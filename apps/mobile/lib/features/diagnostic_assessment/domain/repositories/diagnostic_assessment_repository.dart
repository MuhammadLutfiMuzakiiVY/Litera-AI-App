import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_profile.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_session.dart';

abstract interface class DiagnosticAssessmentRepository {
  Future<DiagnosticSession> startOrResume();

  Future<void> saveAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  });

  Future<DiagnosticProfile> submit({required String sessionId});
}

