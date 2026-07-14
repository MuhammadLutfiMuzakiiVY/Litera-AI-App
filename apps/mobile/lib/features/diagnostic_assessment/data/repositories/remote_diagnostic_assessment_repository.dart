import 'package:litera_ai_mobile/features/diagnostic_assessment/data/datasources/diagnostic_remote_datasource.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/data/mappers/diagnostic_mapper.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_profile.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_session.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/repositories/diagnostic_assessment_repository.dart';

class RemoteDiagnosticAssessmentRepository
    implements DiagnosticAssessmentRepository {
  const RemoteDiagnosticAssessmentRepository(this._remoteDataSource);

  final DiagnosticRemoteDataSource _remoteDataSource;

  @override
  Future<DiagnosticSession> startOrResume() async {
    return (await _remoteDataSource.startOrResume()).toDomain();
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  }) {
    return _remoteDataSource.saveAnswer(
      sessionId: sessionId,
      questionId: questionId,
      selectedOptionId: selectedOptionId,
      responseTimeMs: responseTimeMs,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<DiagnosticProfile> submit({required String sessionId}) async {
    return (await _remoteDataSource.submit(sessionId: sessionId)).toDomain();
  }
}

