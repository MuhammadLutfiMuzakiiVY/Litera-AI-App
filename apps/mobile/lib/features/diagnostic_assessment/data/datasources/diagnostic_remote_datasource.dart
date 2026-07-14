import 'package:dio/dio.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/data/dtos/diagnostic_dtos.dart';

class DiagnosticRemoteDataSource {
  const DiagnosticRemoteDataSource(this._dio);

  final Dio _dio;

  Future<DiagnosticSessionDto> startOrResume() async {
    final response = await _dio.post<Map<String, Object?>>(
      '/assessments/diagnostic-sessions',
    );
    return DiagnosticSessionDto.fromJson(
      response.data ?? const <String, Object?>{},
    );
  }

  Future<void> saveAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  }) async {
    await _dio.post<void>(
      '/assessments/diagnostic-sessions/$sessionId/answers',
      data: {
        'question_id': questionId,
        'selected_option_id': selectedOptionId,
        'response_time_ms': responseTimeMs,
        'idempotency_key': idempotencyKey,
      },
    );
  }

  Future<DiagnosticProfileDto> submit({required String sessionId}) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/assessments/diagnostic-sessions/$sessionId/submit',
    );
    final resultJson =
        response.data?['result'] as Map<String, Object?>? ??
            const <String, Object?>{};
    return DiagnosticProfileDto.fromJson(resultJson);
  }
}
